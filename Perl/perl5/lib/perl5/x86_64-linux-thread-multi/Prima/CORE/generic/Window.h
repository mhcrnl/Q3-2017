/* This file was automatically generated.
 * Do not edit, you'll loose your changes anyway.
 * file: Window.h  */
#ifndef Window_H_
#define Window_H_
#ifndef _APRICOT_H_
#include "apricot.h"
#endif
#include "Widget.h"
#include "Types.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct _Window_vmt {
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
	Color ( *backColor)( Handle self, Bool set, Color value);
	Color ( *color)( Handle self, Bool set, Color value);
	Rect ( *clipRect)( Handle self, Bool set, Rect value);
	Bool ( *fillWinding)( Handle self, Bool set, Bool value);
	SV * ( *fillPattern)( Handle self, Bool set, SV * value);
	int ( *height)( Handle self, Bool set, int value);
	int ( *lineEnd)( Handle self, Bool set, int value);
	int ( *lineJoin)( Handle self, Bool set, int value);
	SV * ( *linePattern)( Handle self, Bool set, SV * value);
	int ( *lineWidth)( Handle self, Bool set, int value);
	SV * ( *palette)( Handle self, Bool set, SV * value);
	SV * ( *pixel)( Handle self, Bool set, int x ,int y, SV * value);
	Handle ( *region)( Handle self, Bool set, Handle value);
	Point ( *resolution)( Handle self, Bool set, Point value);
	int ( *rop)( Handle self, Bool set, int value);
	int ( *rop2)( Handle self, Bool set, int value);
	Point ( *size)( Handle self, Bool set, Point value);
	int ( *splinePrecision)( Handle self, Bool set, int value);
	Bool ( *textOpaque)( Handle self, Bool set, Bool value);
	Bool ( *textOutBaseline)( Handle self, Bool set, Bool value);
	Point ( *translate)( Handle self, Bool set, Point value);
	int ( *width)( Handle self, Bool set, int value);
	Bool ( *begin_paint)( Handle self);
	Bool ( *begin_paint_info)( Handle self);
	void ( *end_paint)( Handle self);
	void ( *end_paint_info)( Handle self);
	Font * ( *font_match)( char * dummy ,Font * source ,Font * dest ,Bool pick );
	Bool ( *font_add)( Handle self, Font * source ,Font * dest );
	void ( *set_font)( Handle self, Font font );
	int ( *get_bpp)( Handle self);
	Font ( *get_font)( Handle self);
	SV * ( *get_font_abc)( Handle self, int first ,int last ,Bool unicode );
	SV * ( *get_font_ranges)( Handle self);
	Color ( *get_nearest_color)( Handle self, Color color );
	int ( *get_paint_state)( Handle self);
	SV * ( *get_physical_palette)( Handle self);
	int ( *get_text_width)( Handle self, SV * text ,Bool addOverhang );
	SV * ( *get_text_box)( Handle self, SV * text );
	SV * ( *render_spline)( SV * obj ,SV * points ,int precision );
	Bool ( *arc)( Handle self, int x ,int y ,int dX ,int dY ,double startAngle ,double endAngle );
	Bool ( *bar)( Handle self, int x1 ,int y1 ,int x2 ,int y2 );
	Bool ( *bars)( Handle self, SV * rects );
	Bool ( *chord)( Handle self, int x ,int y ,int dX ,int dY ,double startAngle ,double endAngle );
	Bool ( *clear)( Handle self, int x1 ,int y1 ,int x2 ,int y2 );
	Bool ( *ellipse)( Handle self, int x ,int y ,int dX ,int dY );
	Bool ( *fill_chord)( Handle self, int x ,int y ,int dX ,int dY ,double startAngle ,double endAngle );
	Bool ( *fill_ellipse)( Handle self, int x ,int y ,int dX ,int dY );
	Bool ( *fillpoly)( Handle self, SV * points );
	Bool ( *fill_sector)( Handle self, int x ,int y ,int dX ,int dY ,double startAngle ,double endAngle );
	Bool ( *fill_spline)( Handle self, SV * points );
	Bool ( *flood_fill)( Handle self, int x ,int y ,Color color ,Bool singleBorder );
	Bool ( *line)( Handle self, int x1 ,int y1 ,int x2 ,int y2 );
	Bool ( *lines)( Handle self, SV * points );
	Bool ( *polyline)( Handle self, SV * points );
	Bool ( *put_image_indirect)( Handle self, Handle image ,int x ,int y ,int xFrom ,int yFrom ,int xDestLen ,int yDestLen ,int xLen ,int yLen ,int rop );
	Bool ( *rectangle)( Handle self, int x1 ,int y1 ,int x2 ,int y2 );
	Bool ( *sector)( Handle self, int x ,int y ,int dX ,int dY ,double startAngle ,double endAngle );
	Bool ( *spline)( Handle self, SV * points );
	Bool ( *text_out)( Handle self, SV * text ,int x ,int y );
	SV * ( *text_wrap)( Handle self, SV * text ,int width ,int options ,int tabIndent );
	SV * ( *accelItems)( Handle self, Bool set, SV * value);
	Handle ( *accelTable)( Handle self, Bool set, Handle value);
	Bool ( *autoEnableChildren)( Handle self, Bool set, Bool value);
	int ( *bottom)( Handle self, Bool set, int value);
	Bool ( *briefKeys)( Handle self, Bool set, Bool value);
	Bool ( *buffered)( Handle self, Bool set, Bool value);
	Bool ( *clipOwner)( Handle self, Bool set, Bool value);
	Color ( *colorIndex)( Handle self, Bool set, int index, Color value);
	Bool ( *current)( Handle self, Bool set, Bool value);
	Handle ( *currentWidget)( Handle self, Bool set, Handle value);
	Point ( *cursorPos)( Handle self, Bool set, Point value);
	Point ( *cursorSize)( Handle self, Bool set, Point value);
	Bool ( *cursorVisible)( Handle self, Bool set, Bool value);
	NPoint ( *designScale)( Handle self, Bool set, NPoint value);
	Bool ( *enabled)( Handle self, Bool set, Bool value);
	int ( *geometry)( Handle self, Bool set, int value);
	int ( *geomHeight)( Handle self, Bool set, int value);
	Point ( *geomSize)( Handle self, Bool set, Point value);
	int ( *geomWidth)( Handle self, Bool set, int value);
	int ( *growMode)( Handle self, Bool set, int value);
	Bool ( *firstClick)( Handle self, Bool set, Bool value);
	Bool ( *focused)( Handle self, Bool set, Bool value);
	SV * ( *helpContext)( Handle self, Bool set, SV * value);
	SV * ( *hint)( Handle self, Bool set, SV * value);
	int ( *hintVisible)( Handle self, Bool set, int value);
	int ( *left)( Handle self, Bool set, int value);
	Handle ( *popup)( Handle self, Bool set, Handle value);
	SV * ( *popupItems)( Handle self, Bool set, SV * value);
	Bool ( *ownerBackColor)( Handle self, Bool set, Bool value);
	Bool ( *ownerColor)( Handle self, Bool set, Bool value);
	Bool ( *ownerFont)( Handle self, Bool set, Bool value);
	Bool ( *ownerHint)( Handle self, Bool set, Bool value);
	Bool ( *ownerShowHint)( Handle self, Bool set, Bool value);
	Bool ( *ownerPalette)( Handle self, Bool set, Bool value);
	Point ( *origin)( Handle self, Bool set, Point value);
	SV * ( *packInfo)( Handle self, Bool set, SV * value);
	SV * ( *placeInfo)( Handle self, Bool set, SV * value);
	Point ( *pointerHotSpot)( Handle self, Bool set, Point value);
	Handle ( *pointerIcon)( Handle self, Bool set, Handle value);
	Point ( *pointerPos)( Handle self, Bool set, Point value);
	int ( *pointerType)( Handle self, Bool set, int value);
	Color ( *popupColorIndex)( Handle self, Bool set, int index, Color value);
	Bool ( *packPropagate)( Handle self, Bool set, Bool value);
	Rect ( *rect)( Handle self, Bool set, Rect value);
	int ( *right)( Handle self, Bool set, int value);
	Bool ( *scaleChildren)( Handle self, Bool set, Bool value);
	Bool ( *selectable)( Handle self, Bool set, Bool value);
	Bool ( *selected)( Handle self, Bool set, Bool value);
	Handle ( *selectedWidget)( Handle self, Bool set, Handle value);
	int ( *selectingButtons)( Handle self, Bool set, int value);
	Handle ( *shape)( Handle self, Bool set, Handle value);
	Bool ( *showHint)( Handle self, Bool set, Bool value);
	Point ( *sizeMax)( Handle self, Bool set, Point value);
	Point ( *sizeMin)( Handle self, Bool set, Point value);
	Bool ( *syncPaint)( Handle self, Bool set, Bool value);
	int ( *tabOrder)( Handle self, Bool set, int value);
	Bool ( *tabStop)( Handle self, Bool set, Bool value);
	SV * ( *text)( Handle self, Bool set, SV * value);
	int ( *top)( Handle self, Bool set, int value);
	Bool ( *transparent)( Handle self, Bool set, Bool value);
	Bool ( *visible)( Handle self, Bool set, Bool value);
	int ( *widgetClass)( Handle self, Bool set, int value);
	void ( *bring_to_front)( Handle self);
	Bool ( *can_close)( Handle self);
	void ( *client_to_screen)( Handle self);
	Bool ( *close)( Handle self);
	Bool ( *custom_paint)( Handle self);
	Bool ( *exposed)( Handle self);
	SV * ( *fetch_resource)( char * className ,char * name ,char * classRes ,char * res ,Handle owner ,int resType );
	Handle ( *first)( Handle self);
	Handle ( *first_that)( Handle self, void * actionProc ,void * params );
	void ( *hide)( Handle self);
	void ( *hide_cursor)( Handle self);
	Bool ( *help)( Handle self);
	void ( *insert_behind)( Handle self, Handle view );
	void ( *invalidate_rect)( Handle self, Rect rect );
	Bool ( *is_child)( Handle self, Handle possibleOwner );
	void ( *key_event)( Handle self, int command ,int code ,int key ,int mod ,int repeat ,Bool post );
	Handle ( *last)( Handle self);
	Bool ( *lock)( Handle self);
	Color ( *map_color)( Handle self, Color color );
	void ( *mouse_event)( Handle self, int command ,int button ,int mod ,int x ,int y ,Bool dblclk ,Bool post );
	Handle ( *next)( Handle self);
	Handle ( *next_tab)( Handle self, Bool forward );
	Handle ( *next_positional)( Handle self, int dx ,int dy );
	Bool ( *process_accel)( Handle self, int key );
	Handle ( *prev)( Handle self);
	void ( *repaint)( Handle self);
	Bool ( *responsive)( Handle self);
	void ( *screen_to_client)( Handle self);
	void ( *scroll)( Handle self, int dx ,int dy ,Rect * confine ,Rect * clip ,Bool withChildren );
	void ( *send_to_back)( Handle self);
	void ( *show)( Handle self);
	void ( *show_cursor)( Handle self);
	Bool ( *showing)( Handle self);
	Bool ( *unlock)( Handle self);
	void ( *update_view)( Handle self);
	Bool ( *validate_rect)( Handle self, Rect rect );
	Bool ( *get_capture)( Handle self);
	Font ( *get_default_font)( char * dummy );
	Font ( *get_default_popup_font)( char * dummy );
	Rect ( *get_invalid_rect)( Handle self);
	Bool ( *get_locked)( Handle self);
	int ( *get_mouse_state)( Handle self);
	void ( *get_pack_slaves)( Handle self);
	Handle ( *get_parent)( Handle self);
	SV * ( *get_parent_handle)( Handle self);
	void ( *get_place_slaves)( Handle self);
	Point ( *get_pointer_size)( char * dummy );
	Font ( *get_popup_font)( Handle self);
	Handle ( *get_selectee)( Handle self);
	int ( *get_shift_state)( Handle self);
	Point ( *get_virtual_size)( Handle self);
	void ( *get_widgets)( Handle self);
	void ( *set_capture)( Handle self, Bool capture ,Handle confineTo );
	void ( *set_centered)( Handle self, Bool x ,Bool y );
	void ( *set_popup_font)( Handle self, Font font );
	void ( *on_paint)( Handle self, SV * canvas );
	int ( *borderIcons)( Handle self, Bool set, int value);
	int ( *borderStyle)( Handle self, Bool set, int value);
	Point ( *frameOrigin)( Handle self, Bool set, Point value);
	Point ( *frameSize)( Handle self, Bool set, Point value);
	Handle ( *icon)( Handle self, Bool set, Handle value);
	Bool ( *mainWindow)( Handle self, Bool set, Bool value);
	Handle ( *menu)( Handle self, Bool set, Handle value);
	Color ( *menuColorIndex)( Handle self, Bool set, int index, Color value);
	SV * ( *menuItems)( Handle self, Bool set, SV * value);
	Bool ( *modalHorizon)( Handle self, Bool set, Bool value);
	int ( *modalResult)( Handle self, Bool set, int value);
	Bool ( *onTop)( Handle self, Bool set, Bool value);
	Bool ( *ownerIcon)( Handle self, Bool set, Bool value);
	Bool ( *taskListed)( Handle self, Bool set, Bool value);
	int ( *windowState)( Handle self, Bool set, int value);
	void ( *cancel)( Handle self);
	void ( *end_modal)( Handle self);
	int ( *execute)( Handle self, Handle insertBefore );
	Bool ( *execute_shared)( Handle self, Handle insertBefore );
	SV * ( *get_client_handle)( Handle self);
	Font ( *get_default_menu_font)( char * dummy );
	Handle ( *get_horizon)( Handle self);
	Font ( *get_menu_font)( Handle self);
	int ( *get_modal)( Handle self);
	Handle ( *get_modal_window)( Handle self, int modalFlag ,Bool next );
	void ( *ok)( Handle self);
	void ( *set_menu_font)( Handle self, Font font );
	void ( *exec_enter_proc)( Handle self, Bool sharedExec ,Handle insertBefore );
	void ( *exec_leave_proc)( Handle self);
	void ( *cancel_children)( Handle self);
} Window_vmt, *PWindow_vmt;

extern PWindow_vmt CWindow;

typedef struct _Window {
/* internal pointers */
	PWindow_vmt self;
	PWidget_vmt super;
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
	Font font;
	int w;
	int h;
	PRGBColor palette;
	int palSize;
	int splinePrecision;
	int splinePrecision_saved;
	PFontABC font_abc_ascii;
	PList font_abc_unicode;
	Handle accelTable;
	Handle currentWidget;
	int cursorLock;
	NPoint designScale;
	char * helpContext;
	char * hint;
	int lockCount;
	Font popupFont;
	ColorSet popupColor;
	Handle popupMenu;
	int pointerType;
	Point pos;
	int selectingButtons;
	Point sizeMin;
	Point sizeMax;
	int tabOrder;
	char * text;
	int widgetClass;
	List widgets;
	Handle * enum_lists;
	int geometry;
	Point geomSize;
	GeomInfo geomInfo;
	int growMode;
	Point virtualSize;
	Handle packSlaves;
	Handle placeSlaves;
	Handle menu;
	Font menuFont;
	ColorSet menuColor;
	int modal;
	int modalResult;
	Handle nextExclModal;
	Handle prevExclModal;
	Handle nextSharedModal;
	Handle prevSharedModal;
	Handle topSharedModal;
} Window, *PWindow;

extern void register_Window_Class( void);

/* Local methods definitions */
extern void Window_cleanup( Handle self);
extern void Window_init( Handle self, HV * profile );
extern SV * Window_profile_default( Handle self);
extern void Window_set( Handle self, HV * profile );
extern void Window_handle_event( Handle self, PEvent event );
extern SV * Window_notification_types( Handle self);
extern void Window_update_sys_handle( Handle self, HV * profile );
extern Bool Window_validate_owner( Handle self, Handle * newOwner ,HV * profile );
extern Point Window_size( Handle self, Bool set, Point value);
extern Bool Window_focused( Handle self, Bool set, Bool value);
extern Point Window_origin( Handle self, Bool set, Point value);
extern Rect Window_rect( Handle self, Bool set, Rect value);
extern Bool Window_selected( Handle self, Bool set, Bool value);
extern SV * Window_text( Handle self, Bool set, SV * value);
extern Bool Window_transparent( Handle self, Bool set, Bool value);
extern Bool Window_process_accel( Handle self, int key );
extern int Window_borderIcons( Handle self, Bool set, int value);
extern int Window_borderStyle( Handle self, Bool set, int value);
extern Point Window_frameOrigin( Handle self, Bool set, Point value);
extern Point Window_frameSize( Handle self, Bool set, Point value);
extern Handle Window_icon( Handle self, Bool set, Handle value);
extern Bool Window_mainWindow( Handle self, Bool set, Bool value);
extern Handle Window_menu( Handle self, Bool set, Handle value);
extern Color Window_menuColorIndex( Handle self, Bool set, int index, Color value);
extern SV * Window_menuItems( Handle self, Bool set, SV * value);
extern Bool Window_modalHorizon( Handle self, Bool set, Bool value);
extern int Window_modalResult( Handle self, Bool set, int value);
extern Bool Window_onTop( Handle self, Bool set, Bool value);
extern Bool Window_ownerIcon( Handle self, Bool set, Bool value);
extern Bool Window_taskListed( Handle self, Bool set, Bool value);
extern int Window_windowState( Handle self, Bool set, int value);
extern void Window_cancel( Handle self);
extern void Window_end_modal( Handle self);
extern int Window_execute( Handle self, Handle insertBefore );
extern Bool Window_execute_shared( Handle self, Handle insertBefore );
extern SV * Window_get_client_handle( Handle self);
extern Font Window_get_default_menu_font( char * dummy );
extern Handle Window_get_horizon( Handle self);
extern Font Window_get_menu_font( Handle self);
extern int Window_get_modal( Handle self);
extern Handle Window_get_modal_window( Handle self, int modalFlag ,Bool next );
extern void Window_ok( Handle self);
extern void Window_set_menu_font( Handle self, Font font );
extern void Window_exec_enter_proc( Handle self, Bool sharedExec ,Handle insertBefore );
extern void Window_exec_leave_proc( Handle self);
extern void Window_cancel_children( Handle self);

#undef  get_widgetClass
#undef  set_widgetClass
#define get_widgetClass(__hs)         widgetClass((__hs),0,(int)0)
#define set_widgetClass(__hs,__val)   widgetClass((__hs),1,(__val))
#undef  get_color
#undef  set_color
#define get_color(__hs)         color((__hs),0,(Color)0)
#define set_color(__hs,__val)   color((__hs),1,(__val))
#undef  get_ownerIcon
#undef  set_ownerIcon
#define get_ownerIcon(__hs)         ownerIcon((__hs),0,(Bool)0)
#define set_ownerIcon(__hs,__val)   ownerIcon((__hs),1,(__val))
#undef  get_syncPaint
#undef  set_syncPaint
#define get_syncPaint(__hs)         syncPaint((__hs),0,(Bool)0)
#define set_syncPaint(__hs,__val)   syncPaint((__hs),1,(__val))
#undef  get_transparent
#undef  set_transparent
#define get_transparent(__hs)         transparent((__hs),0,(Bool)0)
#define set_transparent(__hs,__val)   transparent((__hs),1,(__val))
#undef  get_pointerIcon
#undef  set_pointerIcon
#define get_pointerIcon(__hs)         pointerIcon((__hs),0,(Handle)0)
#define set_pointerIcon(__hs,__val)   pointerIcon((__hs),1,(__val))
#undef  get_pointerType
#undef  set_pointerType
#define get_pointerType(__hs)         pointerType((__hs),0,(int)0)
#define set_pointerType(__hs,__val)   pointerType((__hs),1,(__val))
#undef  get_lineEnd
#undef  set_lineEnd
#define get_lineEnd(__hs)         lineEnd((__hs),0,(int)0)
#define set_lineEnd(__hs,__val)   lineEnd((__hs),1,(__val))
#undef  get_windowState
#undef  set_windowState
#define get_windowState(__hs)         windowState((__hs),0,(int)0)
#define set_windowState(__hs,__val)   windowState((__hs),1,(__val))
#undef  get_tabOrder
#undef  set_tabOrder
#define get_tabOrder(__hs)         tabOrder((__hs),0,(int)0)
#define set_tabOrder(__hs,__val)   tabOrder((__hs),1,(__val))
#undef  get_enabled
#undef  set_enabled
#define get_enabled(__hs)         enabled((__hs),0,(Bool)0)
#define set_enabled(__hs,__val)   enabled((__hs),1,(__val))
#undef  get_geomWidth
#undef  set_geomWidth
#define get_geomWidth(__hs)         geomWidth((__hs),0,(int)0)
#define set_geomWidth(__hs,__val)   geomWidth((__hs),1,(__val))
#undef  get_borderStyle
#undef  set_borderStyle
#define get_borderStyle(__hs)         borderStyle((__hs),0,(int)0)
#define set_borderStyle(__hs,__val)   borderStyle((__hs),1,(__val))
#undef  get_cursorVisible
#undef  set_cursorVisible
#define get_cursorVisible(__hs)         cursorVisible((__hs),0,(Bool)0)
#define set_cursorVisible(__hs,__val)   cursorVisible((__hs),1,(__val))
#undef  get_modalResult
#undef  set_modalResult
#define get_modalResult(__hs)         modalResult((__hs),0,(int)0)
#define set_modalResult(__hs,__val)   modalResult((__hs),1,(__val))
#undef  get_rop
#undef  set_rop
#define get_rop(__hs)         rop((__hs),0,(int)0)
#define set_rop(__hs,__val)   rop((__hs),1,(__val))
#undef  get_menu
#undef  set_menu
#define get_menu(__hs)         menu((__hs),0,(Handle)0)
#define set_menu(__hs,__val)   menu((__hs),1,(__val))
#undef  get_pointerHotSpot
#undef  set_pointerHotSpot
#define get_pointerHotSpot(__hs)         pointerHotSpot((__hs),0,Point_buffer)
#define set_pointerHotSpot(__hs,__val)   pointerHotSpot((__hs),1,(__val))
#undef  get_pixel
#undef  set_pixel
#define get_pixel(__hs)         pixel((__hs),0,(SV *)0)
#define set_pixel(__hs,__val)   pixel((__hs),1,(__val))
#undef  get_accelTable
#undef  set_accelTable
#define get_accelTable(__hs)         accelTable((__hs),0,(Handle)0)
#define set_accelTable(__hs,__val)   accelTable((__hs),1,(__val))
#undef  get_designScale
#undef  set_designScale
#define get_designScale(__hs)         designScale((__hs),0,NPoint_buffer)
#define set_designScale(__hs,__val)   designScale((__hs),1,(__val))
#undef  get_ownerPalette
#undef  set_ownerPalette
#define get_ownerPalette(__hs)         ownerPalette((__hs),0,(Bool)0)
#define set_ownerPalette(__hs,__val)   ownerPalette((__hs),1,(__val))
#undef  get_visible
#undef  set_visible
#define get_visible(__hs)         visible((__hs),0,(Bool)0)
#define set_visible(__hs,__val)   visible((__hs),1,(__val))
#undef  get_selectingButtons
#undef  set_selectingButtons
#define get_selectingButtons(__hs)         selectingButtons((__hs),0,(int)0)
#define set_selectingButtons(__hs,__val)   selectingButtons((__hs),1,(__val))
#undef  get_borderIcons
#undef  set_borderIcons
#define get_borderIcons(__hs)         borderIcons((__hs),0,(int)0)
#define set_borderIcons(__hs,__val)   borderIcons((__hs),1,(__val))
#undef  get_buffered
#undef  set_buffered
#define get_buffered(__hs)         buffered((__hs),0,(Bool)0)
#define set_buffered(__hs,__val)   buffered((__hs),1,(__val))
#undef  get_ownerBackColor
#undef  set_ownerBackColor
#define get_ownerBackColor(__hs)         ownerBackColor((__hs),0,(Bool)0)
#define set_ownerBackColor(__hs,__val)   ownerBackColor((__hs),1,(__val))
#undef  get_size
#undef  set_size
#define get_size(__hs)         size((__hs),0,Point_buffer)
#define set_size(__hs,__val)   size((__hs),1,(__val))
#undef  get_clipOwner
#undef  set_clipOwner
#define get_clipOwner(__hs)         clipOwner((__hs),0,(Bool)0)
#define set_clipOwner(__hs,__val)   clipOwner((__hs),1,(__val))
#undef  get_hintVisible
#undef  set_hintVisible
#define get_hintVisible(__hs)         hintVisible((__hs),0,(int)0)
#define set_hintVisible(__hs,__val)   hintVisible((__hs),1,(__val))
#undef  get_selectable
#undef  set_selectable
#define get_selectable(__hs)         selectable((__hs),0,(Bool)0)
#define set_selectable(__hs,__val)   selectable((__hs),1,(__val))
#undef  get_packInfo
#undef  set_packInfo
#define get_packInfo(__hs)         packInfo((__hs),0,(SV *)0)
#define set_packInfo(__hs,__val)   packInfo((__hs),1,(__val))
#undef  get_fillWinding
#undef  set_fillWinding
#define get_fillWinding(__hs)         fillWinding((__hs),0,(Bool)0)
#define set_fillWinding(__hs,__val)   fillWinding((__hs),1,(__val))
#undef  get_currentWidget
#undef  set_currentWidget
#define get_currentWidget(__hs)         currentWidget((__hs),0,(Handle)0)
#define set_currentWidget(__hs,__val)   currentWidget((__hs),1,(__val))
#undef  get_sizeMax
#undef  set_sizeMax
#define get_sizeMax(__hs)         sizeMax((__hs),0,Point_buffer)
#define set_sizeMax(__hs,__val)   sizeMax((__hs),1,(__val))
#undef  get_origin
#undef  set_origin
#define get_origin(__hs)         origin((__hs),0,Point_buffer)
#define set_origin(__hs,__val)   origin((__hs),1,(__val))
#undef  get_ownerFont
#undef  set_ownerFont
#define get_ownerFont(__hs)         ownerFont((__hs),0,(Bool)0)
#define set_ownerFont(__hs,__val)   ownerFont((__hs),1,(__val))
#undef  get_resolution
#undef  set_resolution
#define get_resolution(__hs)         resolution((__hs),0,Point_buffer)
#define set_resolution(__hs,__val)   resolution((__hs),1,(__val))
#undef  get_text
#undef  set_text
#define get_text(__hs)         text((__hs),0,(SV *)0)
#define set_text(__hs,__val)   text((__hs),1,(__val))
#undef  get_top
#undef  set_top
#define get_top(__hs)         top((__hs),0,(int)0)
#define set_top(__hs,__val)   top((__hs),1,(__val))
#undef  get_helpContext
#undef  set_helpContext
#define get_helpContext(__hs)         helpContext((__hs),0,(SV *)0)
#define set_helpContext(__hs,__val)   helpContext((__hs),1,(__val))
#undef  get_geomHeight
#undef  set_geomHeight
#define get_geomHeight(__hs)         geomHeight((__hs),0,(int)0)
#define set_geomHeight(__hs,__val)   geomHeight((__hs),1,(__val))
#undef  get_focused
#undef  set_focused
#define get_focused(__hs)         focused((__hs),0,(Bool)0)
#define set_focused(__hs,__val)   focused((__hs),1,(__val))
#undef  get_delegations
#undef  set_delegations
#define get_delegations(__hs)         delegations((__hs),0,(SV *)0)
#define set_delegations(__hs,__val)   delegations((__hs),1,(__val))
#undef  get_linePattern
#undef  set_linePattern
#define get_linePattern(__hs)         linePattern((__hs),0,(SV *)0)
#define set_linePattern(__hs,__val)   linePattern((__hs),1,(__val))
#undef  get_ownerColor
#undef  set_ownerColor
#define get_ownerColor(__hs)         ownerColor((__hs),0,(Bool)0)
#define set_ownerColor(__hs,__val)   ownerColor((__hs),1,(__val))
#undef  get_frameSize
#undef  set_frameSize
#define get_frameSize(__hs)         frameSize((__hs),0,Point_buffer)
#define set_frameSize(__hs,__val)   frameSize((__hs),1,(__val))
#undef  get_rop2
#undef  set_rop2
#define get_rop2(__hs)         rop2((__hs),0,(int)0)
#define set_rop2(__hs,__val)   rop2((__hs),1,(__val))
#undef  get_current
#undef  set_current
#define get_current(__hs)         current((__hs),0,(Bool)0)
#define set_current(__hs,__val)   current((__hs),1,(__val))
#undef  get_selected
#undef  set_selected
#define get_selected(__hs)         selected((__hs),0,(Bool)0)
#define set_selected(__hs,__val)   selected((__hs),1,(__val))
#undef  get_growMode
#undef  set_growMode
#define get_growMode(__hs)         growMode((__hs),0,(int)0)
#define set_growMode(__hs,__val)   growMode((__hs),1,(__val))
#undef  get_scaleChildren
#undef  set_scaleChildren
#define get_scaleChildren(__hs)         scaleChildren((__hs),0,(Bool)0)
#define set_scaleChildren(__hs,__val)   scaleChildren((__hs),1,(__val))
#undef  get_firstClick
#undef  set_firstClick
#define get_firstClick(__hs)         firstClick((__hs),0,(Bool)0)
#define set_firstClick(__hs,__val)   firstClick((__hs),1,(__val))
#undef  get_textOutBaseline
#undef  set_textOutBaseline
#define get_textOutBaseline(__hs)         textOutBaseline((__hs),0,(Bool)0)
#define set_textOutBaseline(__hs,__val)   textOutBaseline((__hs),1,(__val))
#undef  get_modalHorizon
#undef  set_modalHorizon
#define get_modalHorizon(__hs)         modalHorizon((__hs),0,(Bool)0)
#define set_modalHorizon(__hs,__val)   modalHorizon((__hs),1,(__val))
#undef  get_right
#undef  set_right
#define get_right(__hs)         right((__hs),0,(int)0)
#define set_right(__hs,__val)   right((__hs),1,(__val))
#undef  get_lineJoin
#undef  set_lineJoin
#define get_lineJoin(__hs)         lineJoin((__hs),0,(int)0)
#define set_lineJoin(__hs,__val)   lineJoin((__hs),1,(__val))
#undef  get_width
#undef  set_width
#define get_width(__hs)         width((__hs),0,(int)0)
#define set_width(__hs,__val)   width((__hs),1,(__val))
#undef  get_menuItems
#undef  set_menuItems
#define get_menuItems(__hs)         menuItems((__hs),0,(SV *)0)
#define set_menuItems(__hs,__val)   menuItems((__hs),1,(__val))
#undef  get_translate
#undef  set_translate
#define get_translate(__hs)         translate((__hs),0,Point_buffer)
#define set_translate(__hs,__val)   translate((__hs),1,(__val))
#undef  get_palette
#undef  set_palette
#define get_palette(__hs)         palette((__hs),0,(SV *)0)
#define set_palette(__hs,__val)   palette((__hs),1,(__val))
#undef  get_menuColorIndex
#undef  set_menuColorIndex
#define get_menuColorIndex(__hs,__var1)         menuColorIndex((__hs),0,(__var1),(Color)0)
#define set_menuColorIndex(__hs,__var1,__val)   menuColorIndex((__hs),1,(__var1),(__val))
#undef  get_height
#undef  set_height
#define get_height(__hs)         height((__hs),0,(int)0)
#define set_height(__hs,__val)   height((__hs),1,(__val))
#undef  get_splinePrecision
#undef  set_splinePrecision
#define get_splinePrecision(__hs)         splinePrecision((__hs),0,(int)0)
#define set_splinePrecision(__hs,__val)   splinePrecision((__hs),1,(__val))
#undef  get_geomSize
#undef  set_geomSize
#define get_geomSize(__hs)         geomSize((__hs),0,Point_buffer)
#define set_geomSize(__hs,__val)   geomSize((__hs),1,(__val))
#undef  get_bottom
#undef  set_bottom
#define get_bottom(__hs)         bottom((__hs),0,(int)0)
#define set_bottom(__hs,__val)   bottom((__hs),1,(__val))
#undef  get_popupColorIndex
#undef  set_popupColorIndex
#define get_popupColorIndex(__hs)         popupColorIndex((__hs),0,(Color)0)
#define set_popupColorIndex(__hs,__val)   popupColorIndex((__hs),1,(__val))
#undef  get_cursorSize
#undef  set_cursorSize
#define get_cursorSize(__hs)         cursorSize((__hs),0,Point_buffer)
#define set_cursorSize(__hs,__val)   cursorSize((__hs),1,(__val))
#undef  get_packPropagate
#undef  set_packPropagate
#define get_packPropagate(__hs)         packPropagate((__hs),0,(Bool)0)
#define set_packPropagate(__hs,__val)   packPropagate((__hs),1,(__val))
#undef  get_icon
#undef  set_icon
#define get_icon(__hs)         icon((__hs),0,(Handle)0)
#define set_icon(__hs,__val)   icon((__hs),1,(__val))
#undef  get_popupItems
#undef  set_popupItems
#define get_popupItems(__hs)         popupItems((__hs),0,(SV *)0)
#define set_popupItems(__hs,__val)   popupItems((__hs),1,(__val))
#undef  get_taskListed
#undef  set_taskListed
#define get_taskListed(__hs)         taskListed((__hs),0,(Bool)0)
#define set_taskListed(__hs,__val)   taskListed((__hs),1,(__val))
#undef  get_owner
#undef  set_owner
#define get_owner(__hs)         owner((__hs),0,(Handle)0)
#define set_owner(__hs,__val)   owner((__hs),1,(__val))
#undef  get_lineWidth
#undef  set_lineWidth
#define get_lineWidth(__hs)         lineWidth((__hs),0,(int)0)
#define set_lineWidth(__hs,__val)   lineWidth((__hs),1,(__val))
#undef  get_backColor
#undef  set_backColor
#define get_backColor(__hs)         backColor((__hs),0,(Color)0)
#define set_backColor(__hs,__val)   backColor((__hs),1,(__val))
#undef  get_frameOrigin
#undef  set_frameOrigin
#define get_frameOrigin(__hs)         frameOrigin((__hs),0,Point_buffer)
#define set_frameOrigin(__hs,__val)   frameOrigin((__hs),1,(__val))
#undef  get_tabStop
#undef  set_tabStop
#define get_tabStop(__hs)         tabStop((__hs),0,(Bool)0)
#define set_tabStop(__hs,__val)   tabStop((__hs),1,(__val))
#undef  get_placeInfo
#undef  set_placeInfo
#define get_placeInfo(__hs)         placeInfo((__hs),0,(SV *)0)
#define set_placeInfo(__hs,__val)   placeInfo((__hs),1,(__val))
#undef  get_onTop
#undef  set_onTop
#define get_onTop(__hs)         onTop((__hs),0,(Bool)0)
#define set_onTop(__hs,__val)   onTop((__hs),1,(__val))
#undef  get_mainWindow
#undef  set_mainWindow
#define get_mainWindow(__hs)         mainWindow((__hs),0,(Bool)0)
#define set_mainWindow(__hs,__val)   mainWindow((__hs),1,(__val))
#undef  get_name
#undef  set_name
#define get_name(__hs)         name((__hs),0,(SV *)0)
#define set_name(__hs,__val)   name((__hs),1,(__val))
#undef  get_shape
#undef  set_shape
#define get_shape(__hs)         shape((__hs),0,(Handle)0)
#define set_shape(__hs,__val)   shape((__hs),1,(__val))
#undef  get_ownerShowHint
#undef  set_ownerShowHint
#define get_ownerShowHint(__hs)         ownerShowHint((__hs),0,(Bool)0)
#define set_ownerShowHint(__hs,__val)   ownerShowHint((__hs),1,(__val))
#undef  get_region
#undef  set_region
#define get_region(__hs)         region((__hs),0,(Handle)0)
#define set_region(__hs,__val)   region((__hs),1,(__val))
#undef  get_rect
#undef  set_rect
#define get_rect(__hs)         rect((__hs),0,Rect_buffer)
#define set_rect(__hs,__val)   rect((__hs),1,(__val))
#undef  get_cursorPos
#undef  set_cursorPos
#define get_cursorPos(__hs)         cursorPos((__hs),0,Point_buffer)
#define set_cursorPos(__hs,__val)   cursorPos((__hs),1,(__val))
#undef  get_accelItems
#undef  set_accelItems
#define get_accelItems(__hs)         accelItems((__hs),0,(SV *)0)
#define set_accelItems(__hs,__val)   accelItems((__hs),1,(__val))
#undef  get_hint
#undef  set_hint
#define get_hint(__hs)         hint((__hs),0,(SV *)0)
#define set_hint(__hs,__val)   hint((__hs),1,(__val))
#undef  get_briefKeys
#undef  set_briefKeys
#define get_briefKeys(__hs)         briefKeys((__hs),0,(Bool)0)
#define set_briefKeys(__hs,__val)   briefKeys((__hs),1,(__val))
#undef  get_textOpaque
#undef  set_textOpaque
#define get_textOpaque(__hs)         textOpaque((__hs),0,(Bool)0)
#define set_textOpaque(__hs,__val)   textOpaque((__hs),1,(__val))
#undef  get_fillPattern
#undef  set_fillPattern
#define get_fillPattern(__hs)         fillPattern((__hs),0,(SV *)0)
#define set_fillPattern(__hs,__val)   fillPattern((__hs),1,(__val))
#undef  get_pointerPos
#undef  set_pointerPos
#define get_pointerPos(__hs)         pointerPos((__hs),0,Point_buffer)
#define set_pointerPos(__hs,__val)   pointerPos((__hs),1,(__val))
#undef  get_geometry
#undef  set_geometry
#define get_geometry(__hs)         geometry((__hs),0,(int)0)
#define set_geometry(__hs,__val)   geometry((__hs),1,(__val))
#undef  get_showHint
#undef  set_showHint
#define get_showHint(__hs)         showHint((__hs),0,(Bool)0)
#define set_showHint(__hs,__val)   showHint((__hs),1,(__val))
#undef  get_autoEnableChildren
#undef  set_autoEnableChildren
#define get_autoEnableChildren(__hs)         autoEnableChildren((__hs),0,(Bool)0)
#define set_autoEnableChildren(__hs,__val)   autoEnableChildren((__hs),1,(__val))
#undef  get_left
#undef  set_left
#define get_left(__hs)         left((__hs),0,(int)0)
#define set_left(__hs,__val)   left((__hs),1,(__val))
#undef  get_ownerHint
#undef  set_ownerHint
#define get_ownerHint(__hs)         ownerHint((__hs),0,(Bool)0)
#define set_ownerHint(__hs,__val)   ownerHint((__hs),1,(__val))
#undef  get_eventFlag
#undef  set_eventFlag
#define get_eventFlag(__hs)         eventFlag((__hs),0,(Bool)0)
#define set_eventFlag(__hs,__val)   eventFlag((__hs),1,(__val))
#undef  get_sizeMin
#undef  set_sizeMin
#define get_sizeMin(__hs)         sizeMin((__hs),0,Point_buffer)
#define set_sizeMin(__hs,__val)   sizeMin((__hs),1,(__val))
#undef  get_selectedWidget
#undef  set_selectedWidget
#define get_selectedWidget(__hs)         selectedWidget((__hs),0,(Handle)0)
#define set_selectedWidget(__hs,__val)   selectedWidget((__hs),1,(__val))
#undef  get_popup
#undef  set_popup
#define get_popup(__hs)         popup((__hs),0,(Handle)0)
#define set_popup(__hs,__val)   popup((__hs),1,(__val))
#undef  get_colorIndex
#undef  set_colorIndex
#define get_colorIndex(__hs)         colorIndex((__hs),0,(Color)0)
#define set_colorIndex(__hs,__val)   colorIndex((__hs),1,(__val))
#undef  get_clipRect
#undef  set_clipRect
#define get_clipRect(__hs)         clipRect((__hs),0,Rect_buffer)
#define set_clipRect(__hs,__val)   clipRect((__hs),1,(__val))

#ifdef __cplusplus
}
#endif
#endif
