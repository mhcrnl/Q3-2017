/* This file was automatically generated.
 * Do not edit, you'll loose your changes anyway.
 * file: AbstractMenu.h  */
#ifndef AbstractMenu_H_
#define AbstractMenu_H_
#ifndef _APRICOT_H_
#include "apricot.h"
#endif
#include "Component.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct _AbstractMenu_vmt {
/* internal runtime classifiers */
	char *className;
	void *super;
	void *base;
	int instanceSize;
	VmtPatch *patch;
	int patchLength;
	int vmtSize;
/* methods definition */
	void ( *cleanup)( Handle self);
	void ( *done)( Handle self);
	void ( *init)( Handle self, HV * profile );
	void ( *profile_add)( Handle self, SV * profile );
	void ( *profile_check_in)( Handle self, SV * profile ,SV * default_profile );
	SV * ( *profile_default)( Handle self);
	void ( *set)( Handle self, HV * profile );
	void ( *setup)( Handle self);
	Bool ( *eventFlag)( Handle self, Bool set, Bool value);
	SV * ( *delegations)( Handle self, Bool set, SV * value);
	SV * ( *name)( Handle self, Bool set, SV * value);
	Handle ( *owner)( Handle self, Bool set, Handle value);
	UV ( *add_notification)( Handle self, char * name ,SV * subroutine ,Handle referer ,int index );
	void ( *attach)( Handle self, Handle objectHandle );
	Handle ( *bring)( Handle self, char * componentName );
	Bool ( *can_event)( Handle self);
	void ( *clear_event)( Handle self);
	void ( *detach)( Handle self, Handle objectHandle ,Bool kill );
	void ( *event_error)( Handle self);
	Handle ( *first_that_component)( Handle self, void * actionProc ,void * params );
	void ( *get_components)( Handle self);
	SV * ( *get_handle)( Handle self);
	void ( *get_notification)( Handle self, char * name ,int index );
	void ( *handle_event)( Handle self, PEvent event );
	int ( *is_owner)( Handle self, Handle objectHandle );
	Bool ( *message)( Handle self, PEvent event );
	Bool ( *migrate)( Handle self, Handle attachTo );
	SV * ( *notification_types)( Handle self);
	Bool ( *notify)( Handle self, char * format ,... );
	Bool ( *pop_event)( Handle self);
	void ( *post_message)( Handle self, SV * info1 ,SV * info2 );
	void ( *push_event)( Handle self);
	void ( *recreate)( Handle self);
	void ( *remove_notification)( Handle self, UV id );
	void ( *set_notification)( Handle self, char * name ,SV * subroutine );
	void ( *unlink_notifier)( Handle self, Handle referer );
	void ( *update_sys_handle)( Handle self, HV * profile );
	Bool ( *validate_owner)( Handle self, Handle * newOwner ,HV * profile );
	Bool ( *selected)( Handle self, Bool set, Bool value);
	SV * ( *accel)( Handle self, Bool set, char * varName, SV * value);
	SV * ( *action)( Handle self, Bool set, char * varName, SV * value);
	Bool ( *checked)( Handle self, Bool set, char * varName, Bool value);
	SV * ( *data)( Handle self, Bool set, char * varName, SV * value);
	Bool ( *enabled)( Handle self, Bool set, char * varName, Bool value);
	Handle ( *image)( Handle self, Bool set, char * varName, Handle value);
	SV * ( *key)( Handle self, Bool set, char * varName, SV * value);
	SV * ( *text)( Handle self, Bool set, char * varName, SV * value);
	void ( *remove)( Handle self, char * varName );
	void * ( *first_that)( Handle self, void * actionProc ,void * params ,Bool useDisabled );
	SV * ( *get_items)( Handle self, char * varName );
	Bool ( *has_item)( Handle self, char * varName );
	void ( *insert)( Handle self, SV * menuItems ,char * rootName ,int index );
	void ( *set_command)( Handle self, char * key ,Bool enabled );
	void ( *set_items)( Handle self, SV * menuItems );
	void ( *set_variable)( Handle self, char * varName ,SV * newName );
	int ( *translate_accel)( Handle self ,char * accel );
	int ( *translate_key)( Handle self ,int code ,int key ,int mod );
	int ( *translate_shortcut)( Handle self ,char * key );
	void ( *dispose_menu)( Handle self, void * menu );
	void * ( *new_menu)( Handle self, SV * sv ,int level );
	Bool ( *sub_call)( Handle self, PMenuItemReg m );
	Bool ( *sub_call_id)( Handle self, int sysId );
	Bool ( *sub_call_key)( Handle self, int key );
	char * ( *make_var_context)( Handle self, PMenuItemReg m ,char * buffer );
	char * ( *make_id_context)( Handle self, int id ,char * buffer );
} AbstractMenu_vmt, *PAbstractMenu_vmt;

extern PAbstractMenu_vmt CAbstractMenu;

typedef struct _AbstractMenu {
/* internal pointers */
	PAbstractMenu_vmt self;
	PComponent_vmt super;
	SV  *mate;
	struct _AnyObject *killPtr;
/* instance variables */
	int stage;
	int protectCount;
	int destroyRefCount;
	Handle owner;
	void * transient_class;
	ObjectOptions options;
	void * sysData;
	char * name;
	ApiHandle handle;
	char * evStack;
	int evPtr;
	int evLimit;
	PList postList;
	PList components;
	PList evQueue;
	PList refs;
	PList events;
	PHash eventIDs;
	int eventIDCount;
	PMenuItemReg tree;
	Bool anchored;
	Bool system;
	unsigned int autoEnum;
} AbstractMenu, *PAbstractMenu;

extern void register_AbstractMenu_Class( void);

/* Local methods definitions */
extern void AbstractMenu_cleanup( Handle self);
extern void AbstractMenu_done( Handle self);
extern void AbstractMenu_init( Handle self, HV * profile );
extern SV * AbstractMenu_profile_default( Handle self);
extern void AbstractMenu_set( Handle self, HV * profile );
extern SV * AbstractMenu_get_handle( Handle self);
extern Bool AbstractMenu_validate_owner( Handle self, Handle * newOwner ,HV * profile );
extern Bool AbstractMenu_selected( Handle self, Bool set, Bool value);
extern SV * AbstractMenu_accel( Handle self, Bool set, char * varName, SV * value);
extern SV * AbstractMenu_action( Handle self, Bool set, char * varName, SV * value);
extern Bool AbstractMenu_checked( Handle self, Bool set, char * varName, Bool value);
extern SV * AbstractMenu_data( Handle self, Bool set, char * varName, SV * value);
extern Bool AbstractMenu_enabled( Handle self, Bool set, char * varName, Bool value);
extern Handle AbstractMenu_image( Handle self, Bool set, char * varName, Handle value);
extern SV * AbstractMenu_key( Handle self, Bool set, char * varName, SV * value);
extern SV * AbstractMenu_text( Handle self, Bool set, char * varName, SV * value);
extern void AbstractMenu_remove( Handle self, char * varName );
extern void * AbstractMenu_first_that( Handle self, void * actionProc ,void * params ,Bool useDisabled );
extern SV * AbstractMenu_get_items( Handle self, char * varName );
extern Bool AbstractMenu_has_item( Handle self, char * varName );
extern void AbstractMenu_insert( Handle self, SV * menuItems ,char * rootName ,int index );
extern void AbstractMenu_set_command( Handle self, char * key ,Bool enabled );
extern void AbstractMenu_set_items( Handle self, SV * menuItems );
extern void AbstractMenu_set_variable( Handle self, char * varName ,SV * newName );
extern int AbstractMenu_translate_accel( Handle self ,char * accel );
extern int AbstractMenu_translate_key( Handle self ,int code ,int key ,int mod );
extern int AbstractMenu_translate_shortcut( Handle self ,char * key );
extern void AbstractMenu_dispose_menu( Handle self, void * menu );
extern void * AbstractMenu_new_menu( Handle self, SV * sv ,int level );
extern Bool AbstractMenu_sub_call( Handle self, PMenuItemReg m );
extern Bool AbstractMenu_sub_call_id( Handle self, int sysId );
extern Bool AbstractMenu_sub_call_key( Handle self, int key );
extern char * AbstractMenu_make_var_context( Handle self, PMenuItemReg m ,char * buffer );
extern char * AbstractMenu_make_id_context( Handle self, int id ,char * buffer );

#undef  get_name
#undef  set_name
#define get_name(__hs)         name((__hs),0,(SV *)0)
#define set_name(__hs,__val)   name((__hs),1,(__val))
#undef  get_image
#undef  set_image
#define get_image(__hs,__var1)         image((__hs),0,(__var1),(Handle)0)
#define set_image(__hs,__var1,__val)   image((__hs),1,(__var1),(__val))
#undef  get_accel
#undef  set_accel
#define get_accel(__hs,__var1)         accel((__hs),0,(__var1),(SV *)0)
#define set_accel(__hs,__var1,__val)   accel((__hs),1,(__var1),(__val))
#undef  get_text
#undef  set_text
#define get_text(__hs,__var1)         text((__hs),0,(__var1),(SV *)0)
#define set_text(__hs,__var1,__val)   text((__hs),1,(__var1),(__val))
#undef  get_delegations
#undef  set_delegations
#define get_delegations(__hs)         delegations((__hs),0,(SV *)0)
#define set_delegations(__hs,__val)   delegations((__hs),1,(__val))
#undef  get_action
#undef  set_action
#define get_action(__hs,__var1)         action((__hs),0,(__var1),(SV *)0)
#define set_action(__hs,__var1,__val)   action((__hs),1,(__var1),(__val))
#undef  get_enabled
#undef  set_enabled
#define get_enabled(__hs,__var1)         enabled((__hs),0,(__var1),(Bool)0)
#define set_enabled(__hs,__var1,__val)   enabled((__hs),1,(__var1),(__val))
#undef  get_selected
#undef  set_selected
#define get_selected(__hs)         selected((__hs),0,(Bool)0)
#define set_selected(__hs,__val)   selected((__hs),1,(__val))
#undef  get_owner
#undef  set_owner
#define get_owner(__hs)         owner((__hs),0,(Handle)0)
#define set_owner(__hs,__val)   owner((__hs),1,(__val))
#undef  get_data
#undef  set_data
#define get_data(__hs,__var1)         data((__hs),0,(__var1),(SV *)0)
#define set_data(__hs,__var1,__val)   data((__hs),1,(__var1),(__val))
#undef  get_eventFlag
#undef  set_eventFlag
#define get_eventFlag(__hs)         eventFlag((__hs),0,(Bool)0)
#define set_eventFlag(__hs,__val)   eventFlag((__hs),1,(__val))
#undef  get_checked
#undef  set_checked
#define get_checked(__hs,__var1)         checked((__hs),0,(__var1),(Bool)0)
#define set_checked(__hs,__var1,__val)   checked((__hs),1,(__var1),(__val))
#undef  get_key
#undef  set_key
#define get_key(__hs,__var1)         key((__hs),0,(__var1),(SV *)0)
#define set_key(__hs,__var1,__val)   key((__hs),1,(__var1),(__val))

#ifdef __cplusplus
}
#endif
#endif
