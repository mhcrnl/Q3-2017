#ifndef __ITEMCONFIG_HH__
#define __ITEMCONFIG_HH__

// This file class represents the validated and normalized contents of
// Abuild.conf files.  For efficiency, non-const methods are not
// thread-safe.  Abuild only calls them in the main thread before
// starting the worker threads.

#include <string>
#include <set>
#include <map>
#include <list>
#include <boost/shared_ptr.hpp>
#include <FileLocation.hh>
#include <KeyVal.hh>
#include <FlagData.hh>
#include <TraitData.hh>
#include <PlatformSelector.hh>

class Error;
class CompatLevel;

class ItemConfig
{
  public:
    enum Backend
    {
	b_none,
	b_make,
	b_groovy,
	b_ant
    };

    class BuildAlso
    {
      public:
	BuildAlso(std::string const& name, bool is_tree);
	void setDesc();
	void setWithTreeDeps();

	bool isTree() const;
	void getDetails(std::string& name,
			bool& is_tree,
			bool& desc,
			bool& with_tree_deps) const;
	// Define a sensible ordering so BuildAlso objects can be map
	// keys or stored in sets.
	bool operator==(BuildAlso const&) const;
	bool operator<(BuildAlso const&) const;

      private:
	unsigned int getOrderNum() const;

	std::string name;
	bool is_tree;
	bool desc;
	bool with_tree_deps;
    };

    // Read the FILE_CONF file in dir and return a pointer to it.  The
    // ItemConfig class manages the memory.  The "dir" parameter must
    // be a canonical path.  For efficiency, this is not checked.
    static ItemConfig* readConfig(Error& error_handler,
				  CompatLevel const& compat_level,
				  std::string const& dir,
				  std::string const& parent_dir);
    static bool isNameValid(std::string const& name);

    static std::string const FILE_CONF;
    static std::string const FILE_INTERFACE;

    // configuration file keys
    static std::string const k_NAME;
    static std::string const k_TREENAME;
    static std::string const k_DESCRIPTION;
    static std::string const k_CHILDREN;
    static std::string const k_BUILD_ALSO;
    static std::string const k_DEPS;
    static std::string const k_TREEDEPS;
    static std::string const k_VISIBLE_TO;
    static std::string const k_PLATFORM;
    static std::string const k_SUPPORTED_FLAGS;
    static std::string const k_SUPPORTED_TRAITS;
    static std::string const k_TRAITS;
    static std::string const k_PLUGINS;
    static std::string const k_ATTRIBUTES;
    static std::string const ITEM_NAME_RE;
    static std::string const BUILD_ALSO_RE;
    static std::string const PARENT_RE;
    static std::map<std::string, std::string> valid_keys;

    bool isTreeRoot() const;
    bool isForestRoot() const;
    bool isChildOnly() const;
    bool usesDeprecatedFeatures() const;
    bool hasExternalSymlinks() const;
    std::string const& getAbsolutePath() const;
    std::string const& getParentDir() const;
    std::string const& getName() const;
    std::string const& getTreeName() const;
    std::string const& getDescription() const;
    std::list<std::string> const& getChildren() const;
    std::list<std::string> const& getExternals() const;
    std::list<BuildAlso> const& getBuildAlso() const;
    std::list<std::string> const& getDeps() const;
    std::list<std::string> const& getTreeDeps() const;
    std::set<std::string> const& getOptionalDeps() const;
    std::set<std::string> const& getOptionalTreeDeps() const;
    std::string const& getDepPlatformType(std::string const& dep,
					  PlatformSelector const*& ps) const;
    FlagData const& getFlagData() const;
    TraitData const& getTraitData() const;
    std::string const& getVisibleTo() const;
    std::set<std::string> const& getPlatformTypes() const;
    bool hasBuildFile() const;
    FileLocation const& getLocation() const;
    bool supportsFlag(std::string const& flag) const;
    std::set<std::string> const& getSupportedFlags() const;
    std::set<std::string> const& getSupportedTraits() const;
    std::set<std::string> const& getDeleted() const;
    Backend getBackend() const;
    bool hasAntBuild() const;
    std::string const& getBuildFile() const;
    std::list<std::string> const& getPlugins() const;
    bool hasGlobalPlugins() const;
    std::set<std::string> const& getGlobalPlugins() const;
    bool isSerial() const;
    bool childIsOptional(std::string const& child) const;

    // For 1.0 to 1.1 upgrade process
    bool upgradeConfig(std::string const& file,
		       std::set<std::string> const& new_children,
		       std::string const& tree_name,
		       std::list<std::string> const& externals,
		       std::list<std::string> const& new_tree_deps);

  private:
    ItemConfig(ItemConfig const&);
    ItemConfig& operator=(ItemConfig const&);

    // deprecated configuration file keys
    static std::string const k_THIS;
    static std::string const k_PARENT;
    static std::string const k_EXTERNAL;
    static std::string const k_DELETED;

    static std::string const FILE_MK;
    static std::string const FILE_ANT;
    static std::string const FILE_ANT_BUILD;
    static std::string const FILE_GROOVY;

    static KeyVal const& readKeyVal(Error& error_handler,
				    CompatLevel const& compat_level,
				    std::string const& dir);

    static void initializeStatics(CompatLevel const&);
    static bool statics_initialized;

    void validate();
    void detectRoot();
    void findParentDir();
    void checkDeprecated();
    void checkUnnamed();
    void checkRoot();
    void checkName();
    void checkTreeName();
    void checkParent();
    void checkChildren();
    void checkBuildAlso();
    void checkDeps();
    void checkTreeDeps();
    void checkVisibleTo();
    void checkBuildfile();
    void checkPlatforms();
    void checkExternals();
    void checkSupportedFlags();
    void checkSupportedTraits();
    void checkTraits();
    void checkDeleted();
    void checkPlugins();
    void checkAttributes();

    bool validName(std::string const& name, std::string const& description);

    // These methods return true if they found any errors.  This is
    // useful for constructing coverage cases.
    bool filterInvalidNames(std::set<std::string>& names,
			    std::string const& description);
    bool checkKeyPresent(std::string const& key, std::string const& msg);
    bool checkDuplicates(std::list<std::string> const& declared,
			 std::set<std::string>& filtered,
			 std::string const& thing);
    bool checkRelativePaths(std::list<std::string>& paths,
			    std::string const& description);
    bool hasSymlinks(std::string const& path);
    void maybeSetBuildFile(std::string const& file, int& count);

    ItemConfig(Error&, CompatLevel const&, FileLocation const&,
	       KeyVal const&, std::string const& dir,
	       std::string const& parent_dir);

    typedef boost::shared_ptr<KeyVal> KeyVal_ptr;
    static std::map<std::string, KeyVal_ptr> kv_cache;
    typedef boost::shared_ptr<ItemConfig> ItemConfig_ptr;
    static std::map<std::string, ItemConfig_ptr> ic_cache;

    Error& error;
    CompatLevel const& compat_level;
    FileLocation location;
    KeyVal kv;
    std::string dir;
    std::string parent_dir;
    bool is_root;
    bool is_forest_root;
    bool is_child_only;
    bool deprecated;
    bool external_symlinks;

    // Information used during validation
    std::string buildfile;

    // Information read from the file
    std::string name;
    std::list<std::string> children;
    std::list<BuildAlso> build_also;
    std::list<std::string> deps;
    std::list<std::string> tree_deps;
    FlagData flag_data;
    std::string visible_to;
    std::set<std::string> platform_types;
    std::string tree_name;
    std::list<std::string> externals;
    std::set<std::string> supported_flags;
    std::set<std::string> supported_traits;
    TraitData trait_data;
    std::set<std::string> deleted;
    std::string description;
    std::list<std::string> plugins;
    std::map<std::string, std::string> dep_platform_types;
    std::map<std::string,
	     boost::shared_ptr<PlatformSelector> > dep_platform_selectors;
    std::set<std::string> optional_deps;
    std::set<std::string> optional_tree_deps;
    std::set<std::string> optional_children;
    std::set<std::string> global_plugins;
    bool serial;
};

#endif // __ITEMCONFIG_HH__
