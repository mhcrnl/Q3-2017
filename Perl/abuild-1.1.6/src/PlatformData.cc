#include <PlatformData.hh>
#include <QEXC.hh>
#include <Util.hh>
#include <QTC.hh>
#include <assert.h>
#include <sstream>
#include <algorithm>
#include <boost/regex.hpp>
#include <boost/bind.hpp>

std::string const PlatformData::PLATFORM_INDEP = "indep";
std::string const PlatformData::PLATFORM_JAVA = "java";
std::string const PlatformData::pt_INDEP = "indep";
std::string const PlatformData::pt_NATIVE = "native";
std::string const PlatformData::pt_JAVA = "java";
std::string const PlatformData::PLATFORM_PREFIX = "platform ";
std::string const PlatformData::PLATFORM_TYPE_PREFIX = "platform type ";

PlatformData::PlatformData() :
    initializing(true),
    checked(false)
{
    // Prepopulate with built-in types.
    addPlatformType(pt_INDEP, TargetType::tt_platform_independent);
    addPlatformType(pt_NATIVE, TargetType::tt_object_code);
    addPlatformType(pt_JAVA, TargetType::tt_java);
    addPlatform(PLATFORM_INDEP, pt_INDEP, false);
    addPlatform(PLATFORM_JAVA, pt_JAVA, false);
    this->initializing = false;
}

void
PlatformData::addPlatformType(std::string const& platform_type,
			      TargetType::target_type_e target_type,
			      std::string const& parent_platform_type)
{
    this->checked = false;

    if (! (this->initializing || (target_type == TargetType::tt_object_code)))
    {
	throw QEXC::General("platform types may not be added to target type " +
			    TargetType::getName(target_type));
    }
    if (this->target_types.count(platform_type))
    {
	throw QEXC::General("platform type " + platform_type +
			    " has been registered multiple times");
    }
    this->target_types[platform_type] = target_type;
    this->platform_type_parents[platform_type] = parent_platform_type;

    std::string pt_item = PLATFORM_TYPE_PREFIX + platform_type;

    this->platform_graph.addItem(pt_item);

    if (! parent_platform_type.empty())
    {
	// target_type can only be other than object code during
	// initialization, and we don't pass any parent platform types
	// during initialization.
	assert(target_type == TargetType::tt_object_code);

	if (this->target_types.count(parent_platform_type) == 0)
	{
	    QTC::TC("abuild", "PlatformData ERR unknown parent");
	    throw QEXC::General("platform type \"" + platform_type +
				"\" has unknown parent type \"" +
				parent_platform_type + "\"");
	}
	if (this->target_types[parent_platform_type] !=
	    TargetType::tt_object_code)
	{
	    QTC::TC("abuild", "PlatformData ERR non-object-code parent");
	    throw QEXC::General(
		"platform type \"" + platform_type +
		"\" has parent type " + parent_platform_type +
		"\", which is not in target type \"" +
		TargetType::getName(TargetType::tt_object_code) + "\"");
	}
	std::string ptp_item = PLATFORM_TYPE_PREFIX + parent_platform_type;
	this->platform_graph.addDependency(pt_item, ptp_item);
    }
}

void
PlatformData::addPlatform(std::string const& platform,
			  std::string const& platform_type,
			  bool lowpri)
{
    this->checked = false;

    if (this->platform_declaration.count(platform))
    {
	throw QEXC::General("platform " + platform +
			    " has already been registered");
    }

    // Track the order in which platforms were declared.  We don't
    // care whether size() is evaluated before or after the key is
    // inserted as long as we get monotonically increasing platform
    // priority numbers.  Later additions take precedence over earlier
    // additions, so higher numbers are higher priority.  If the
    // platform was declared as low priority, make it a more negative
    // number than any previous declaration.
    int n = this->platform_declaration.size();
    this->platform_declaration[platform] = (lowpri ? -n : n);

    std::string p_item = PLATFORM_PREFIX + platform;
    this->platform_graph.addItem(p_item);

    if (this->target_types.count(platform_type) == 0)
    {
	throw QEXC::General("platform " + platform +
			    " belongs to unknown platform type " +
			    platform_type);
    }
    std::string pt_item = PLATFORM_TYPE_PREFIX + platform_type;
    this->platform_graph.addDependency(pt_item, p_item);
    this->platform_types[platform] = platform_type;
}

void
PlatformData::check(std::map<std::string, PlatformSelector> const& selectors,
		    std::map<std::string, std::string>& unused_selectors)
{
    this->checked = true;
    if (! this->platform_graph.check())
    {
	std::ostringstream errors;

	// We could go to a lot of trouble to make the error messages
	// more friendly, but since these error conditions cannot be
	// caused by normal users (only be people writing and
	// installing platform support), it seems more worthwhile to
	// just explain the error messages.
	DependencyGraph::ItemMap unknowns;
	std::vector<DependencyGraph::ItemList> cycles;
	this->platform_graph.getErrors(unknowns, cycles);

	for (DependencyGraph::ItemMap::iterator iter = unknowns.begin();
	     iter != unknowns.end(); ++iter)
	{
	    std::string const& node = (*iter).first;
	    DependencyGraph::ItemList const& unknown_items = (*iter).second;
	    for (DependencyGraph::ItemList::const_iterator i2 =
		     unknown_items.begin();
		 i2 != unknown_items.end(); ++i2)
	    {
		std::string const& unknown = *i2;
		errors << "  " << node << " contains unknown item " + unknown
		       << std::endl;
	    }
	}

	for (std::vector<DependencyGraph::ItemList>::const_iterator iter =
		 cycles.begin();
	     iter != cycles.end(); ++iter)
	{
	    DependencyGraph::ItemList const& data = *iter;
	    std::string cycle = Util::join(" -> ", data);
	    cycle += " -> " + data.front();
	    errors << "  circular nesting detected: " << cycle;
	}

	throw QEXC::General(errors.str());
    }

    // If everything is okay, initialize platforms_by_type
    this->platforms_by_type.clear();
    boost::regex platform_re(PLATFORM_PREFIX + "(\\S+)");
    boost::regex platform_type_re(PLATFORM_TYPE_PREFIX + "(\\S+)");
    boost::smatch match;

    for (std::map<std::string, TargetType::target_type_e>::const_iterator iter =
	     this->target_types.begin();
	 iter != this->target_types.end(); ++iter)
    {
	// The logic about how to apply platform selectors to deciding
	// which platform to pick is partially duplicated in
	// BuildItem::getBestPlatformForType.  Please be sure to study
	// both sections of code before making changes to ensure that
	// the changes are consistent.
	std::string const& platform_type = (*iter).first;
	TargetType::target_type_e target_type = (*iter).second;
	PlatformSelector const* ps = 0;
	bool used_selector = false;
	std::string which_selector;
	if (selectors.count(platform_type) != 0)
	{
	    ps = &((*(selectors.find(platform_type))).second);
	    which_selector = platform_type;
	}
	else if ((target_type == TargetType::tt_object_code) &&
		 selectors.count(PlatformSelector::ANY))
	{
	    ps = &((*(selectors.find(PlatformSelector::ANY))).second);
	    which_selector = PlatformSelector::ANY;
	}
	if (ps && (! ps->isSkip()) &&
	    (target_type != TargetType::tt_object_code))
	{
	    QTC::TC("abuild", "PlatformData bad non-object-code selector");
	    throw QEXC::General(
		"platform selectors for non-object-code platform types"
		" may only specify skip");
	}

	selected_platforms_t& platforms =
	    this->platforms_by_type[platform_type];

	std::list<std::string> deps =
	    this->platform_graph.getDirectDependencies(
		PLATFORM_TYPE_PREFIX + platform_type);
	for (std::list<std::string>::iterator dep_iter = deps.begin();
	     dep_iter != deps.end(); ++dep_iter)
	{
	    if (boost::regex_match(*dep_iter, match, platform_re))
	    {
		std::string const& platform = match[1].str();
		platforms.push_back(std::make_pair(platform, false));
	    }
	}

	std::list<std::string> sdeps =
	    this->platform_graph.getSortedDependencies(
		PLATFORM_TYPE_PREFIX + platform_type);
	sdeps.pop_back();
	compatible_platform_types[platform_type].empty(); // force to exist
	for (std::list<std::string>::reverse_iterator dep_iter = sdeps.rbegin();
	     dep_iter != sdeps.rend(); ++dep_iter)
	{
	    if (boost::regex_match(*dep_iter, match, platform_type_re))
	    {
		std::string const& dep_type = match[1].str();
		compatible_platform_types[platform_type].push_back(dep_type);
	    }
	}

	// Sort by priority
	if (! platforms.empty())
	{
	    // First, sort by reverse declaration order.
	    std::sort(platforms.begin(), platforms.end(),
		      boost::bind(&PlatformData::declarationOrder,
				  this, _1, _2));

	    bool select_default = true;
	    if (ps)
	    {
		if (ps->isSkip())
		{
		    // Ignore all platforms in this platform type.
		    QTC::TC("abuild", "PlatformData skipping platform type");
		    select_default = false;
		    used_selector = true;
		}
		else if (ps->isDefault())
		{
		    used_selector = true;
		}
		else
		{
		    bool any_selected = false;

		    // If we have selection criteria, mark each
		    // matching platform.  We must do this after the
		    // initial sort because we need to know what would
		    // have been the highest priority platform to
		    // initialize the matcher.
		    PlatformSelector::Matcher m(platforms[0].first, *ps);
		    for (selected_platforms_t::iterator iter =
			     platforms.begin();
			 iter != platforms.end(); ++iter)
		    {
			(*iter).second = m.matches((*iter).first);
			if ((*iter).second)
			{
			    any_selected = true;
			}
		    }

		    if (any_selected)
		    {
			select_default = false;
			used_selector = true;
		    }
		}
	    }

	    // If no explicit selection (including skip) has been mde,
	    // select the first platform.
	    if (select_default)
	    {
		platforms[0].second = true;
	    }
	}

	if (ps && used_selector)
	{
	    unused_selectors.erase(which_selector);
	}
    }
}

bool
PlatformData::declarationOrder(selected_platform_t const& p1,
			       selected_platform_t const& p2) const
{
    assert(this->platform_declaration.count(p1.first) != 0);
    assert(this->platform_declaration.count(p2.first) != 0);
    return ((*(this->platform_declaration.find(p1.first))).second >
	    (*(this->platform_declaration.find(p2.first))).second);
}

bool
PlatformData::isPlatformTypeValid(std::string const& platform_type) const
{
    assert(this->checked);
    return (this->platforms_by_type.count(platform_type) != 0);
}

TargetType::target_type_e
PlatformData::getTargetType(std::string const& platform_type) const
{
    assert(isPlatformTypeValid(platform_type));
    return (*(this->target_types.find(platform_type))).second;
}

PlatformData::selected_platforms_t const&
PlatformData::getPlatformsByType(std::string const& platform_type) const
{
    assert(isPlatformTypeValid(platform_type));
    return (*(this->platforms_by_type.find(platform_type))).second;
}

std::vector<std::string>
PlatformData::getCompatiblePlatformTypes(
    std::string const& platform) const
{
    std::vector<std::string> result;
    if (this->platform_types.count(platform))
    {
	std::string const& platform_type =
	    (*(this->platform_types.find(platform))).second;
	assert(isPlatformTypeValid(platform_type));
	assert(this->compatible_platform_types.count(platform_type));
	result = (*(this->compatible_platform_types.
		    find(platform_type))).second;
    }
    if (platform != PLATFORM_INDEP)
    {
	// All types are compatible with indep
	result.push_back(pt_INDEP);
    }
    return result;
}

std::set<std::string>
PlatformData::getPlatformTypes(TargetType::target_type_e target_type) const
{
    std::set<std::string> result;
    for (std::map<std::string, TargetType::target_type_e>::const_iterator iter =
	     this->target_types.begin();
	 iter != this->target_types.end(); ++iter)
    {
	if ((*iter).second == target_type)
	{
	    result.insert((*iter).first);
	}
    }
    return result;
}

std::string const&
PlatformData::getPlatformTypeParent(std::string const& platform_type) const
{
    assert(isPlatformTypeValid(platform_type));
    return (*(this->platform_type_parents.find(platform_type))).second;
}
