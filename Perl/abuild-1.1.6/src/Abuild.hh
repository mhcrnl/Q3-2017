#ifndef __ABUILD_HH__
#define __ABUILD_HH__

#include <string>
#include <list>
#include <set>
#include <map>
#include <boost/shared_ptr.hpp>
#include <boost/function.hpp>
#include <boost/regex.hpp>
#include <JavaBuilder.hh>
#include <Error.hh>
#include <QEXC.hh>
#include <BuildForest.hh>
#include <DependencyGraph.hh>
#include <DependencyEvaluator.hh>
#include <Interface.hh>
#include <PlatformData.hh>
#include <PlatformSelector.hh>
#include <CompatLevel.hh>
#include <TargetType.hh>
#include <Logger.hh>
#include <Util.hh>

class ItemConfig;
class InterfaceParser;
class UpgradeData;
class BackingConfig;

class Abuild
{
  public:
    Abuild(int argc, char* argv[]);
    ~Abuild();
    bool run();

  private:
    Abuild(Abuild const&);
    Abuild& operator=(Abuild const&);

    enum output_mode_e { om_unset, om_raw, om_buffered, om_interleaved };

    typedef boost::shared_ptr<BuildForest> BuildForest_ptr;
    typedef std::map<std::string, BuildForest_ptr> BuildForest_map;

    static bool initializeStatics();

    typedef BuildForest::BuildItem_ptr BuildItem_ptr;
    typedef BuildForest::BuildItem_map BuildItem_map;
    typedef BuildForest::BuildTree_ptr BuildTree_ptr;
    typedef BuildForest::BuildTree_map BuildTree_map;
    typedef boost::function<bool(std::string const&, std::string const&)>
            item_filter_t;

    // Helper class for help system
    class HelpTopic
    {
      public:
	HelpTopic()
	{
	}
	HelpTopic(std::string const& item_name,
		  std::string const& tree_name,
		  TargetType::target_type_e target_type,
		  std::string const& filename) :
	    item_name(item_name),
	    tree_name(tree_name),
	    target_type(target_type),
	    filename(filename)
	{
	}
	std::string item_name;
	std::string tree_name;
	TargetType::target_type_e target_type;
	std::string filename;
    };
    typedef std::vector<HelpTopic> HelpTopic_vec;
    typedef std::map<std::string, HelpTopic_vec,
		     Util::StringCaseLess> HelpTopic_map;

    bool runInternal();
    void getThisPlatform();
    void parseArgv();
    void argPositional(std::string const&);
    void argVersion();
    void argHelp(std::vector<std::string> const&);
    void argFindConf();
    void argSetJobs(unsigned int);
    void argSetMakeJobs(unsigned int);
    void argSetKeepGoing();
    void argSetOutputMode(output_mode_e);
    void argSetNoOp();
    void argSetEmacs();
    void argSetBackendArgs(std::vector<std::string> const&,
			   std::list<std::string>&);
    void argSetJVMXargs(std::vector<std::string> const&, bool replace);
    void argSetDeprecationIsError();
    void argSetVerbose();
    void argSetSilent();
    void argSetCompatLevel(std::string& var, boost::smatch const&);
    void argSetBuildSet(std::string const&);
    void argSetCleanSet(std::string const&);
    void argSetBool(bool& var, bool val);
    void argSetString(std::string& var, std::string const& val);
    void argSetStringSplit(std::list<std::string>& var,
			   std::string const& val);
    void argInsertInSet(std::set<std::string>& var, std::string const& val);
    void checkRoRwPaths();
    void checkValidPaths(std::set<std::string>& paths);
    bool anyFirstNotUnderSomeSecond(
	std::set<std::string> const& first,
	std::set<std::string> const& second);
    std::string findConf();
    void checkBuildsetName(std::string const& kind, std::string& name);
    void initializePlatforms();
    void initializeJavaPlatforms();
    void loadPlatformData(PlatformData&, std::string const& dir);
    bool readConfigs();
    ItemConfig* readConfig(std::string const& dir,
			   std::string const& parent_dir);
    ItemConfig* readExternalConfig(std::string const& dir,
				   std::string const& external);
    std::string findTop(std::string const& start_dir,
			std::string const& description);
    void traverse(BuildForest_map&, std::string const& forest_top);
    void reportDirectoryGraphErrors(DependencyGraph& g,
				    std::string const& description);
    void computeBackingGraph(BuildForest_map& forests,
			     DependencyGraph& g);
    void traverseForests(BuildForest_map&, DependencyGraph& external_graph,
			 std::string const& forest_top,
			 std::set<std::string>& visiting,
			 std::string const& description);
    void mergeForests(BuildForest_map& forests,
		      DependencyGraph& external_graph);
    void removeEmptyTrees(BuildForest_map& forests);
    void traverseItems(BuildForest& forest, DependencyGraph& external_graph,
		       std::string const& top_path,
		       std::list<std::string>& dirs_with_externals,
		       std::list<std::string>& backing_areas,
		       std::set<std::string>& deleted_trees,
		       std::set<std::string>& deleted_items);
    void addItemToForest(BuildForest& forest, std::string const& item_name,
			 BuildItem_ptr item);
    std::string registerBuildTree(BuildForest& forest,
				  std::string const& dir,
				  ItemConfig* config,
				  std::list<std::string>& dirs_with_externals);
    void addTreeToForest(BuildForest& forest, std::string const& tree_name,
			 BuildTree_ptr tree);
    std::string getAssignedTreeName(std::string const& dir,
				    bool use_backing_name_only = false);
    std::string getAssignedTreeName(std::string const& dir,
				    std::set<std::string>& visiting,
				    bool use_backing_name_only);
    void validateForest(BuildForest_map& forests,
			std::string const& top_path);
    void resolveFromBackingAreas(BuildForest_map& forests,
				 std::string const& top_path);
    void checkTreeDependencies(BuildForest& forest);
    bool checkAllowedTreeItem(BuildForest& forest,
			      BuildItem& referrer_item,
			      BuildItem& referent_item,
			      std::string const& action);
    bool checkAllowedTreeTree(BuildForest& forest,
			      BuildItem& referrer_item,
			      std::string const& referent_tree,
			      std::string const& action);
    void resolveTraits(BuildForest& forest);
    void checkPlugins(BuildForest& forest);
    bool isPlugin(std::string const& item_name);
    void checkPlatformTypes(BuildForest& forest);
    void checkItemNames(BuildForest& forest);
    bool accessibleFrom(BuildItem_map& builditems,
			std::string const& accessor,
			std::string const& accessee);
    void checkBuildAlso(BuildForest& forest);
    void checkItemDependencies(BuildForest& forest);
    void checkDepTreeAccess(BuildForest& forest);
    void updatePlatformTypes(BuildForest& forest);
    void checkDependencyPlatformTypes(BuildForest& forest);
    void checkFlags(BuildForest& forest);
    void checkTraits(BuildForest& forest);
    void checkIntegrity(BuildForest_map& forests,
			std::string const& top_path);
    void reportIntegrityErrors(BuildForest_map& forests,
			       BuildItem_map& builditems,
			       std::string const& top_path);
    void computeBuildablePlatforms(BuildForest& forest);
    void appendBackingData(std::string const& dir,
			   std::list<std::string>& backing_areas,
			   std::set<std::string>& deleted_trees,
			   std::set<std::string>& deleted_items);
    BackingConfig* readBacking(std::string const& dir);
    void computeValidTraits(BuildForest_map& forests);
    void listTraits();
    void listPlatforms(BuildForest_map& forests);
    void dumpData(BuildForest_map& forests);
    void dumpPlatformData(PlatformData const&, std::string const& indent);
    void dumpBuildTree(BuildTree& tree, std::string const& tree_name,
		       BuildForest& forest,
		       std::map<std::string, int>& forest_numbers);
    void dumpBuildItem(BuildItem& item, std::string const& item_name,
		       std::map<std::string, int>& forest_numbers);
    void dumpBuildAlso(bool trees,
		       std::list<ItemConfig::BuildAlso> const& data);
    void computeTreePrefixes(std::list<std::string> const& tree_names);
    void computeItemPrefixes();
    bool isBuildItemWritable(BuildItem const& item);
    void computeBuildset(BuildTree_map& buildtrees, BuildItem_map& builditems);
    bool populateBuildset(BuildItem_map& builditems,
			  boost::function<bool(BuildItem const*)> pred);
    bool addBuildAlsoToBuildset(BuildTree_map& buildtrees,
				BuildItem_map& builditems);
    bool itemIsInBuildAlso(
	BuildItem const* item,
	BuildTree_map& buildtrees, BuildItem_map& builditems,
	std::set<ItemConfig::BuildAlso> const& build_also);
    bool buildBuildset();
    bool addItemToBuildGraph(std::string const& item_name, BuildItem& item);
    std::string createBuildGraphNode(std::string const& item_name,
				     std::string const& platform);
    void parseBuildGraphNode(std::string const& node,
			     std::string& item_name,
			     std::string& platform);
    void findGnuMakeInPath();
    void findJava();
    bool isThisItemThisPlatform(std::string const& name,
				std::string const& platform);
    bool isThisItem(std::string const& name, std::string const& platform);
    bool isAnyItem(std::string const& name, std::string const& platform);
    bool itemBuilder(std::string builder_string, item_filter_t filter,
		     bool is_dep_failure);
    bool buildItem(boost::mutex::scoped_lock& build_lock,
		   Logger::job_handle_t logger_job,
		   std::string const& item_name,
		   std::string const& item_platform,
		   BuildItem& build_item);
    std::string createOutputDirectory(std::string const& item_platform,
				      BuildItem& build_item);
    void stateChangeCallback(std::string const& builder_string,
			     DependencyEvaluator::ItemState state,
			     item_filter_t filter);
    bool createItemInterface(std::string const& builder_string,
			     std::string const& item_name,
			     std::string const& item_platform,
			     BuildItem& build_item,
			     Error& item_error,
			     InterfaceParser& parser,
			     Logger::job_handle_t logger_job);
    bool createPluginInterface(std::string const& plugin_name,
			       BuildItem& build_item);
    void dumpInterface(std::string const& item_platform,
		       BuildItem& build_item,
		       std::string const& suffix = "");
    void declareInterfaceVariable(Error&, Interface&, FileLocation const&,
				  std::string const& variable_name,
				  Interface::scope_e scope,
				  Interface::type_e type,
				  Interface::list_e list_type,
				  bool& status);
    void assignInterfaceVariable(Error&, Interface&, FileLocation const&,
				 std::string const& variable_name,
				 std::string const& value,
				 Interface::assign_e assignment_type,
				 bool& status);
    bool readAfterBuilds(std::string const& item_name,
			 std::string const& item_platform,
			 BuildItem& build_item,
			 InterfaceParser& parser,
			 Logger::job_handle_t logger_job);
    std::list<std::string> getRulePaths(
	std::string const& item_name,
	BuildItem& build_item,
	std::string const& dir,
	bool relative);
    void appendRulePaths(std::list<std::string>& rules_dirs,
			 std::string const& dir,
			 TargetType::target_type_e desired_type);
    std::list<std::string> getToolchainPaths(
	std::string const& item_name,
	BuildItem& build_item,
	std::string const& dir,
	bool relative);
    void appendToolchainPaths(std::list<std::string>& toolchain_dirs,
			      std::string const& dir);
    bool invoke_gmake(boost::mutex::scoped_lock& build_lock,
		      Logger::job_handle_t logger_job,
		      std::string const& item_name,
		      std::string const& item_platform,
		      BuildItem& build_item,
		      std::string const& dir,
		      std::list<std::string> const& targets);
    bool invoke_ant(boost::mutex::scoped_lock& build_lock,
		    Logger::job_handle_t logger_job,
		    std::string const& item_name,
		    std::string const& item_platform,
		    BuildItem& build_item,
		    std::string const& dir,
		    std::list<std::string> const& targets);
    bool invoke_groovy(boost::mutex::scoped_lock& build_lock,
		       Logger::job_handle_t logger_job,
		       std::string const& item_name,
		       std::string const& item_platform,
		       BuildItem& build_item,
		       std::string const& dir,
		       std::list<std::string> const& targets);
    bool invokeJavaBuilder(boost::mutex::scoped_lock& build_lock,
			   Logger::job_handle_t logger_job,
			   std::string const& backend,
			   std::string const& build_file,
			   std::string const& dir,
			   std::list<std::string> const& targets);
    bool invokeBackend(boost::mutex::scoped_lock& build_lock,
		       Logger::job_handle_t logger_job,
		       std::string const& progname,
		       std::vector<std::string> const& args,
		       std::map<std::string, std::string> const& environment,
		       std::string const& dir);
    void flushLogIfSingleThreaded();
    void cleanBuildset();
    void cleanPath(std::string const& item_name, std::string const& dir);
    void cleanOutputDir();
    bool generalHelp();
    void showRulesHelpMessage();
    void readHelpFile(std::string const& filename);
    void rulesHelp(BuildForest& forest);
    void appendToolchainHelpTopics(HelpTopic_map& topics,
				   std::string const& item_name,
				   std::string const& tree_name,
				   std::string const& dir);
    void appendRuleHelpTopics(HelpTopic_map& topics,
			      std::string const& item_name,
			      std::string const& tree_name,
			      std::string const& dir);
    void appendHelpTopics(HelpTopic_map& topics,
			  std::string const& item_name,
			  std::string const& tree_name,
			  TargetType::target_type_e target_type,
			  std::string const& dir);
    bool showHelpFiles(HelpTopic_map& topics,
		       std::string const& module_type,
		       std::string const& module_name);
    void listHelpTopics(HelpTopic_map& topics, std::string const& description,
			std::set<std::string>& references);
    void usage(std::string const& msg);
    void exitIfErrors();
    void info(std::string const& msg,
	      Logger::job_handle_t = Logger::NO_JOB);
    void notice(std::string const& msg,
		Logger::job_handle_t = Logger::NO_JOB);
    void incrementVerboseIndent();
    void decrementVerboseIndent();
    void verbose(std::string const& msg,
		 Logger::job_handle_t = Logger::NO_JOB);
    void monitorOutput(std::string const& msg);
    void monitorErrorCallback(std::string const& msg);
    void error(std::string const& msg,
	       Logger::job_handle_t = Logger::NO_JOB);
    void error(FileLocation const&, std::string const& msg,
	       Logger::job_handle_t = Logger::NO_JOB,
	       bool count_as_error = true);
    void deprecate(std::string const& version,
		   std::string const& msg,
		   Logger::job_handle_t = Logger::NO_JOB);
    void deprecate(std::string const& version,
		   FileLocation const& location,
		   std::string const& msg,
		   Logger::job_handle_t = Logger::NO_JOB);
    void suggestUpgrade();
    void fatal(std::string const& msg);

    // methods in Abuild-upgrade.cc
    bool upgradeTrees();
    void findBuildItems(UpgradeData&);
    void constructTreeGraph(UpgradeData&, DependencyGraph& g);
    void validateProposedForests(
	UpgradeData&,
	std::vector<DependencyGraph::ItemList> const& forests);
    std::string getForestRoot(std::list<std::string> const& forest);
    void initializeForests(
	UpgradeData& ud,
	std::vector<DependencyGraph::ItemList> const& forests);
    void allowUnnamedForestRoots(UpgradeData&);
    void upgradeForests(UpgradeData&);

    static std::string const ABUILD_VERSION;
    static std::string const OUTPUT_DIR_PREFIX;
    static std::string const FILE_DYNAMIC_MK;
    static std::string const FILE_DYNAMIC_ANT;
    static std::string const FILE_DYNAMIC_GROOVY;
    static std::string const FILE_INTERFACE_DUMP;
    static std::string const b_ALL;
    static std::string const b_DEPTREES;
    static std::string const b_DESCDEPTREES;
    static std::string const b_LOCAL;
    static std::string const b_DESC;
    static std::string const b_DEPS;
    static std::string const b_CURRENT;
    static std::set<std::string> valid_buildsets;
    static std::map<std::string, std::string> buildset_aliases;
    static std::string const s_CLEAN;
    static std::string const s_NO_OP;
    static std::string const h_HELP;
    static std::string const h_RULES;
    static std::string const hr_HELP;
    static std::string const hr_LIST;
    static std::string const hr_RULE;
    static std::string const hr_TOOLCHAIN;
    static std::string const PLUGIN_PLATFORM;
    static std::string const FILE_PLUGIN_INTERFACE;
    static std::set<std::string> special_targets;
    static std::list<std::string> default_targets;

    static bool statics_initialized;

    int argc;
    char** argv;

    // Parameters determined from the command line or at startup
    std::string whoami;
    bool stdout_is_tty;
    std::string help_topic;
    std::string rules_help_topic;
    unsigned int max_workers;
    int make_njobs;
    output_mode_e output_mode;
    bool capture_output;
    bool use_job_prefix;
    std::string output_prefix;
    std::string error_prefix;
    std::list<std::string> make_args;
    std::list<std::string> java_builder_args;
    std::list<std::string> jvm_xargs;
    bool test_java_builder_bad_java;
    std::map<std::string, std::string> defines;
    std::string start_dir;
    bool keep_going;
    bool no_dep_failures;
    bool explicit_buildset;
    std::string buildset_name;
    std::set<std::string> buildset_named_items;
    std::string buildset_pattern;
    std::string cleanset_name;
    bool full_integrity;
    bool list_traits;
    bool list_platforms;
    bool dump_data;
    std::string to_find;
    bool dump_build_graph;
    bool verbose_mode;
    bool silent;
    bool monitored;
    bool dump_interfaces;
    std::string special_target;
    std::list<std::string> targets;
    bool apply_targets_to_deps;
    bool with_rdeps;
    bool repeat_expansion;
    std::set<std::string> explicit_target_items;
    std::list<std::string> only_with_traits;
    std::list<std::string> related_by_traits;
    std::map<std::string, PlatformSelector> platform_selectors;
    std::set<std::string> clean_platforms;
    CompatLevel compat_level;
    std::set<std::string> ro_paths;
    std::set<std::string> rw_paths;
    bool default_writable;
    bool local_build;

    // Other data
    boost::mutex build_mutex;
    Error error_handler;
    std::string current_directory;
    std::string program_fullpath;
    std::string abuild_top;
    std::string native_os;
    std::string native_cpu;
    std::string native_toolset;
    std::string this_platform;
    std::string this_config_dir;
    std::string local_tree;
    ItemConfig* this_config;
    PlatformData internal_platform_data;
    std::map<std::string, std::string> unused_platform_selectors;
    std::set<std::string> valid_traits;
    BuildItem_map buildset;
    std::set<std::string> plugins;
#ifdef _WIN32
    bool have_perl;
#endif
    std::string gmake;
    boost::shared_ptr<JavaBuilder> java_builder;
    DependencyGraph build_graph;
    std::set<std::string> forced_failures;
    boost::shared_ptr<Interface> base_interface;
    std::vector<std::string> buildset_reverse_order;
    std::map<std::string, std::string> buildgraph_tree_prefixes;
    std::map<std::string, std::string> buildgraph_item_prefixes;
    std::vector<std::string> failed_builds;
    std::string verbose_indent;

    std::map<std::string, std::string> find_top_cache;
    std::map<std::string,
	     std::map<std::string, ItemConfig*> > read_external_config_cache;

    // Used by 1.0 compatibility mode only.  When removing 1.0
    // compatibility code, search for "compat" to make sure all
    // comments, local variables, etc., are found.
    unsigned int last_assigned_tree_number;
    std::map<std::string, std::string> assigned_tree_names;
    std::set<std::string> items_traversed;
    bool suggest_upgrade;
    std::set<std::string> deprecated_backing_files;

    Logger& logger;
    ProcessHandler& process_handler;
};

#endif // __ABUILD_HH__
