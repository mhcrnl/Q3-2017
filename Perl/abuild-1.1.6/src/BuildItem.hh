#ifndef __BUILDITEM_HH__
#define __BUILDITEM_HH__

#include <string>
#include <list>
#include <set>
#include <boost/shared_ptr.hpp>
#include <TargetType.hh>
#include <Interface.hh>
#include <ItemConfig.hh>
#include <PlatformData.hh>
#include <boost/regex.hpp>

class BuildItem
{
  public:
    BuildItem(std::string const& item_name,
	      std::string const& tree_name,
	      ItemConfig const* config);

    // Proxy methods to ItemConfig
    std::string const& getName() const;
    std::string const& getDescription() const;
    std::list<std::string> const& getChildren() const;
    std::list<ItemConfig::BuildAlso> const& getBuildAlso() const;
    std::string const& getDepPlatformType(std::string const&) const;
    std::string const& getDepPlatformType(
	std::string const&, PlatformSelector const*&) const;
    bool supportsFlag(std::string const& flag) const;
    std::set<std::string> const& getSupportedFlags() const;
    std::string const& getVisibleTo() const;
    bool hasBuildFile() const;
    FileLocation const& getLocation() const;
    ItemConfig::Backend getBackend() const;
    bool hasAntBuild() const;
    std::string const& getBuildFile() const;
    std::string const& getAbsolutePath() const;
    std::set<std::string> const& getOptionalDeps() const;
    bool isSerial() const;

    std::list<std::string> const& getDeps() const;
    FlagData const& getFlagData() const;
    TraitData const& getTraitData() const;
    std::string const& getTreeName() const;
    void setForestRoot(std::string const&);
    std::string const& getForestRoot() const;
    // Note: list does not include the item itself
    std::list<std::string> const& getExpandedDependencies() const;
    unsigned int getBackingDepth() const;
    bool isLocal() const;
    bool isInTree(std::string const& tree) const;
    bool isInTrees(std::set<std::string> const& trees) const;
    bool isInTreesAndAtOrBelowPath(std::set<std::string> const& trees,
				   std::string const& path) const;
    std::set<std::string> const& getShadowedReferences() const;
    std::set<std::string> getPlatformTypes() const;
    std::string const& getPlatformType(std::string const& platform) const;
    std::set<std::string> getBuildablePlatforms() const;
    std::set<std::string> const& getBuildPlatforms() const;
    std::string getBestPlatformForType(
	std::string platform_type,
	PlatformSelector const*,
	std::map<std::string, PlatformSelector> const& platform_selectors) const;
    std::string getBestPlatformForPlatform(
	BuildItem const& item, std::string const& platform,
	std::map<std::string, PlatformSelector> const& platform_selectors) const;
    TargetType::target_type_e getTargetType() const;
    bool isNamed(std::set<std::string>& item_names) const;
    bool matchesPattern(boost::regex& pattern) const;
    bool isAtOrBelowPath(std::string const& path) const;
    bool hasShadowedReferences() const;
    Interface const& getInterface(std::string const& platform) const;
    // True iff item has all listed traits.  Returns true if list is empty.
    bool hasTraits(std::list<std::string> const& traits) const;
    std::list<std::string> const& getPlugins() const;
    // Return a list of all items this item references, including itself
    std::set<std::string> getReferences() const;
    std::map<std::string, bool> const& getOptionalDependencyPresence() const;

    void incrementBackingDepth();
    void setOptionalDependencyPresence(std::string const& item, bool);
    void setPlatformTypes(std::set<std::string> const& platform_types);
    void setTargetType(TargetType::target_type_e target_type);
    void setBuildablePlatforms(
	std::string const& platform_type,
	std::vector<std::string> const& buildable_platforms);
    void setBuildablePlatforms(std::set<std::string> const&);
    void setPlatformData(boost::shared_ptr<PlatformData> platform_data);
    void setBuildPlatforms(std::set<std::string> const&);
    void addBuildPlatform(std::string const&);

    // Note: if last item of passed-in list of expanded dependencies
    // is the item itself, it is removed.
    void setExpandedDependencies(std::list<std::string> const&);

    void setShadowedReferences(std::set<std::string> const&);
    void setInterface(std::string const& platform,
		      boost::shared_ptr<Interface>);
    void setPlugins(std::list<std::string> const&);

  private:
    // allow copying

    // platform type -> [ buildable platform, ... ]
    typedef std::map<std::string, std::vector<std::string> > pt_map;

    void assertLocal() const;

    std::string item_name;
    ItemConfig const* config;         // memory managed by ItemConfig
    std::list<std::string> deps;
    FlagData flag_data;
    TraitData trait_data;
    std::map<std::string, bool> optional_dep_presence;
    std::string tree_name;	      // containing tree
    std::string forest_root;	      // containing forest
    unsigned int backing_depth;	      // 0 in local build tree and externals
    pt_map platform_types;	      // platform types and associated platforms
    std::map<std::string, std::string> platform_to_type;
    std::set<std::string> build_platforms; // platforms we will build on
    boost::shared_ptr<PlatformData> platform_data;
    std::list<std::string> expanded_dependencies; // recursively expanded
    std::set<std::string> shadowed_references;
    std::map<std::string, boost::shared_ptr<Interface> > interfaces;
    TargetType::target_type_e target_type;
    std::list<std::string> plugins;
};

#endif // __BUILDITEM_HH__
