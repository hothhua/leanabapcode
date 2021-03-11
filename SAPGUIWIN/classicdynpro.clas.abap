
*-------------------------------------------------------------*
*如何获取下拉框选择值
*add 20210226
*--------------------------------------------------------------*

TYPE-POOLS: vrm.

DATA: gt_list     TYPE vrm_values.
DATA: gwa_list    TYPE vrm_value.
DATA: gt_values   TYPE TABLE OF dynpread,
      gwa_values  TYPE dynpread.

DATA: gv_selected_value(10) TYPE c.
*--------------------------------------------------------------*
*Selection-Screen
*--------------------------------------------------------------*
PARAMETERS: list TYPE c AS LISTBOX VISIBLE LENGTH 20.
*--------------------------------------------------------------*
*At Selection Screen
*--------------------------------------------------------------*
AT SELECTION-SCREEN ON list.
  CLEAR: gwa_values, gt_values.
  REFRESH gt_values.
  gwa_values-fieldname = 'LIST'.
  APPEND gwa_values TO gt_values.
  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname             = sy-cprog
      dynumb             = sy-dynnr
      translate_to_upper = 'X'
    TABLES
      dynpfields         = gt_values.

  READ TABLE gt_values INDEX 1 INTO gwa_values.
  IF sy-subrc = 0 AND gwa_values-fieldvalue IS NOT INITIAL.
    READ TABLE gt_list INTO gwa_list
                      WITH KEY key = gwa_values-fieldvalue.
    IF sy-subrc = 0.
      gv_selected_value = gwa_list-text.
    ENDIF.
  ENDIF.
*--------------------------------------------------------------*
*Initialization
*--------------------------------------------------------------*
INITIALIZATION.
  gwa_list-key = '1'.
  gwa_list-text = 'Product'.
  APPEND gwa_list TO gt_list.
  gwa_list-key = '2'.
  gwa_list-text = 'Collection'.
  APPEND gwa_list TO gt_list.
  gwa_list-key = '3'.
  gwa_list-text = 'Color'.
  APPEND gwa_list TO gt_list.
  gwa_list-key = '4'.
  gwa_list-text = 'Count'.
  APPEND gwa_list TO gt_list.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = 'LIST'
      values          = gt_list
    EXCEPTIONS
      id_illegal_name = 1
      OTHERS          = 2.
*--------------------------------------------------------------*
*Start of Selection
*--------------------------------------------------------------*
START-OF-SELECTION.
  WRITE:/ gv_selected_value.
  
  *-------------------------------------------------------------*
*如何获取下拉框选择值
*end 20210226
*-------------------------------------------------------------



**  实现全选checkbox  20210226
*-------------------------------------------------------------

* Constants

*-------------------------------------------------------------

CONSTANTS: c_title(10) VALUE 'Options'.

*-------------------------------------------------------------

* Selection Screen

*-------------------------------------------------------------

SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE v_name.

SELECTION-SCREEN: SKIP.

PARAMETERS: cb_all AS CHECKBOX USER-COMMAND uc.

SELECTION-SCREEN: SKIP.

PARAMETERS: cb_a AS CHECKBOX,

cb_b AS CHECKBOX,

cb_c AS CHECKBOX,

cb_d AS CHECKBOX,

cb_e AS CHECKBOX.

SELECTION-SCREEN: END OF BLOCK b1.

*-------------------------------------------------------------

* At Selection Screen Event

*-------------------------------------------------------------

AT SELECTION-SCREEN.

IF sy-ucomm = 'UC'.

IF cb_all = 'X'.

cb_a = cb_b = cb_c = cb_d = cb_e = 'X'.

ELSE.

Clear: cb_a, cb_b, cb_c, cb_d, cb_e.

ENDIF.

ENDIF.

*-------------------------------------------------------------

* Initialization

*-------------------------------------------------------------

INITIALIZATION.

v_name = c_title.


***  endend



**** start new  ****

*&---------------------------------------------------------------------*
*& Report  demo_cfw                                                    *
*&---------------------------------------------------------------------*

REPORT demo_cfw.

*&---------------------------------------------------------------------*
*& Global Declarations                                                 *
*&---------------------------------------------------------------------*

* Class Definitions

CLASS screen_handler DEFINITION CREATE PRIVATE.
  PUBLIC SECTION.
    CLASS-DATA screen TYPE REF TO screen_handler.
    CLASS-METHODS create_screen.
    METHODS constructor.
  PRIVATE SECTION.
    DATA: container_html  TYPE REF TO cl_gui_custom_container,
          container_box   TYPE REF TO cl_gui_dialogbox_container,
          picture         TYPE REF TO cl_gui_picture,
          tree            TYPE REF TO cl_gui_simple_tree,
          html_viewer     TYPE REF TO cl_gui_html_viewer,
          list_viewer     TYPE REF TO cl_gui_alv_grid.
    METHODS: fill_tree,
             fill_picture,
             handle_node_double_click
               FOR EVENT node_double_click OF cl_gui_simple_tree
               IMPORTING node_key,
             close_box
               FOR EVENT close OF cl_gui_dialogbox_container,
             fill_html IMPORTING i_carrid TYPE spfli-carrid,
             fill_list IMPORTING i_carrid TYPE spfli-carrid
                                 i_connid TYPE spfli-connid.
ENDCLASS.                    "screen_handler DEFINITION

* Class Implementations

CLASS screen_handler IMPLEMENTATION.

  METHOD create_screen.
    IF screen IS INITIAL.
      CREATE OBJECT screen.
    ENDIF.
  ENDMETHOD.                    "create_screen

  METHOD constructor.
    DATA: l_event_tab        TYPE cntl_simple_events,
          l_event            LIKE LINE OF l_event_tab,
          l_docking          TYPE REF TO cl_gui_docking_container,
          l_splitter         TYPE REF TO cl_gui_splitter_container,
          l_container_screen TYPE REF TO cl_gui_custom_container,
          l_container_top    TYPE REF TO cl_gui_container,
          l_container_bottom TYPE REF TO cl_gui_container.

    CREATE OBJECT container_html
           EXPORTING container_name = 'CUSTOM_CONTROL'.

    CREATE OBJECT l_docking
           EXPORTING side = cl_gui_docking_container=>dock_at_left
                     extension = 135.

    CREATE OBJECT l_splitter
           EXPORTING parent = l_docking
                     rows = 2
                     columns = 1.

    l_splitter->set_border(
         EXPORTING border = cl_gui_cfw=>false ).

    l_splitter->set_row_mode(
         EXPORTING mode = l_splitter->mode_absolute ).

    l_splitter->set_row_height(
         EXPORTING id = 1
                   height = 180 ).

    l_container_top    =
      l_splitter->get_container( row = 1 column = 1 ).
    l_container_bottom =
      l_splitter->get_container( row = 2 column = 1 ).

    CREATE OBJECT picture
           EXPORTING parent = l_container_top.

    CREATE OBJECT tree
           EXPORTING parent = l_container_bottom
                     node_selection_mode =
                       cl_gui_simple_tree=>node_sel_mode_single.

    l_event-eventid = cl_gui_simple_tree=>eventid_node_double_click.
    l_event-appl_event = ' '.   "system event, does not trigger PAI
    APPEND l_event TO l_event_tab.
    tree->set_registered_events(
         EXPORTING events = l_event_tab ).
    SET HANDLER me->handle_node_double_click FOR tree.

    me->fill_picture( ).
    me->fill_tree( ).
  ENDMETHOD.                    "constructor

  METHOD fill_picture.
    TYPES pict_line TYPE x LENGTH 1022.
    DATA l_mime_api   TYPE REF TO if_mr_api.
    DATA l_pict_wa    TYPE xstring.
    DATA l_pict_tab   TYPE TABLE OF pict_line.
    DATA l_url        TYPE c LENGTH 255.

    l_mime_api = cl_mime_repository_api=>get_api( ).

    l_mime_api->get(
      EXPORTING i_url = '/SAP/PUBLIC/BC/ABAP/Sources/PLANE.GIF'
      IMPORTING e_content = l_pict_wa
      EXCEPTIONS OTHERS = 4 ).

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    l_pict_tab =
      VALUE #( LET l1 = xstrlen( l_pict_wa ) l2 = l1 - 1022 IN
               FOR j = 0 THEN j + 1022  UNTIL j >= l1
                 ( COND #( WHEN j <= l2 THEN
                                l_pict_wa+j(1022)
                           ELSE l_pict_wa+j ) ) ).

    CALL FUNCTION 'DP_CREATE_URL'
      EXPORTING
        type    = 'IMAGE'
        subtype = 'GIF'
      TABLES
        data    = l_pict_tab
      CHANGING
        url     = l_url.

    picture->load_picture_from_url(
         EXPORTING url = l_url ).
    picture->set_display_mode(
         EXPORTING display_mode = picture->display_mode_stretch ).
  ENDMETHOD.                    "fill_picture

  METHOD fill_tree.
    DATA: l_node_table TYPE TABLE OF abdemonode,
          l_node TYPE abdemonode,
          BEGIN OF l_spfli,
            carrid TYPE spfli-carrid,
            connid TYPE spfli-connid,
          END OF l_spfli,
          l_spfli_tab LIKE SORTED TABLE OF l_spfli
                      WITH UNIQUE KEY carrid connid.

    SELECT carrid, connid
      FROM spfli
      INTO CORRESPONDING FIELDS OF TABLE @l_spfli_tab.

    l_node-hidden = ' '.               " All nodes are visible,
    l_node-disabled = ' '.             " selectable,
    l_node-isfolder = 'X'.             " a folder,
    l_node-expander = ' '.             " have no '+' sign for expansion.

    LOOP AT l_spfli_tab INTO l_spfli.
      AT NEW carrid.
        l_node-node_key = l_spfli-carrid.
        CLEAR l_node-relatkey.
        CLEAR l_node-relatship.
        l_node-text = l_spfli-carrid.
        l_node-n_image =   ' '.
        l_node-exp_image = ' '.
        APPEND l_node TO l_node_table.
      ENDAT.
      AT NEW connid.
        l_node-node_key = l_spfli-carrid && l_spfli-connid.
        l_node-relatkey = l_spfli-carrid.
        l_node-relatship = cl_gui_simple_tree=>relat_last_child.
        l_node-text = l_spfli-connid.
        l_node-n_image =   '@AV@'.     "AV is the internal code
        l_node-exp_image = '@AV@'.     "for an airplane icon
      ENDAT.
      APPEND l_node TO l_node_table.
    ENDLOOP.

    tree->add_nodes(
         EXPORTING table_structure_name = 'ABDEMONODE'
                   node_table = l_node_table ).
  ENDMETHOD.                    "fill_tree

  METHOD handle_node_double_click.
    DATA: l_carrid TYPE spfli-carrid,
          l_connid TYPE spfli-connid.

    l_carrid = node_key(2).
    l_connid = node_key+2(4).
    IF l_connid IS INITIAL.
      fill_html( EXPORTING i_carrid = l_carrid ).
    ELSE.
      fill_list( EXPORTING i_carrid = l_carrid
                           i_connid = l_connid ).
    ENDIF.
  ENDMETHOD.                    "handle_node_double_click

  METHOD fill_html.
    DATA l_url TYPE scarr-url.

    IF html_viewer IS INITIAL.
      CREATE OBJECT html_viewer
             EXPORTING parent = container_html.
    ENDIF.

    SELECT SINGLE url
           FROM   scarr
           WHERE  carrid = @i_carrid
           INTO   @l_url.

    html_viewer->show_url(
         EXPORTING url = l_url ).
  ENDMETHOD.                    "fill_html

  METHOD fill_list.
    DATA: l_flight_tab TYPE TABLE OF demofli,
          BEGIN OF l_flight_title,
            carrname TYPE scarr-carrname,
            cityfrom TYPE spfli-cityfrom,
            cityto   TYPE spfli-cityto,
          END OF l_flight_title,
          l_list_layout TYPE lvc_s_layo.

    IF container_box IS INITIAL.
      CREATE OBJECT container_box
             EXPORTING width  = 250
                       height = 200
                       top    = 100
                       left   = 400
                       caption = 'Flight List'.
      SET HANDLER close_box FOR container_box.
      CREATE OBJECT list_viewer
             EXPORTING i_parent = container_box.
    ENDIF.

    SELECT SINGLE c~carrname, p~cityfrom, p~cityto
           FROM   ( scarr AS c
                      INNER JOIN spfli AS p ON c~carrid = p~carrid )
           WHERE  p~carrid = @i_carrid AND
                  p~connid = @i_connid
           INTO   CORRESPONDING FIELDS OF @l_flight_title.

    SELECT   fldate, seatsmax, seatsocc
             FROM     sflight
             WHERE    carrid = @i_carrid AND connid = @i_connid
             ORDER BY fldate
             INTO     CORRESPONDING FIELDS OF TABLE @l_flight_tab.

    l_list_layout-grid_title = l_flight_title-carrname && ` ` &&
                               i_connid                && ` ` &&
                               l_flight_title-cityfrom && ` ` &&
                               l_flight_title-cityto.

    l_list_layout-smalltitle = 'X'.    "The list title has small fonts,
    l_list_layout-cwidth_opt = 'X'.    "the column width is adjusted,
    l_list_layout-no_toolbar = 'X'.    "the toolbar is suppressed.

    list_viewer->set_table_for_first_display(
         EXPORTING i_structure_name = 'DEMOFLI'
                   is_layout        = l_list_layout
         CHANGING  it_outtab        = l_flight_tab ).
  ENDMETHOD.                    "fill_list

  METHOD close_box.
    list_viewer->free( ).
    container_box->free( ).
    CLEAR: list_viewer,
           container_box.
  ENDMETHOD.                    "close_box

ENDCLASS.                    "screen_handler IMPLEMENTATION

*&---------------------------------------------------------------------*
*& Processing Blocks called by the Runtime Environment                 *
*&---------------------------------------------------------------------*

* Event Block START-OF-SELECTION

START-OF-SELECTION.
  CALL SCREEN 100.

* Dialog Module PBO

MODULE status_0100 OUTPUT.
  SET PF-STATUS 'SCREEN_100'.
  SET TITLEBAR 'TIT_100'.
  screen_handler=>create_screen( ).
ENDMODULE.                    "status_0100 OUTPUT

* Dialog Module PAI

MODULE cancel INPUT.
  LEAVE PROGRAM.
ENDMODULE.                    "cancel INPUT


*** end ****


***  start dynpro: Screens, Screen Sequences **

PROGRAM sapmdemo_screen_flow MESSAGE-ID demo_flight.

TABLES: spfli,
        sairport,
        scarr.

DATA: ok_code   TYPE c LENGTH 4,
      rcode     TYPE c LENGTH 5,
      old_spfli TYPE spfli.

* PBO

MODULE status_0100 OUTPUT.
  SET PF-STATUS 'TD0100'.
  SET TITLEBAR '100'.
ENDMODULE.

MODULE status_0200 OUTPUT.
  SET PF-STATUS 'TD0200'.
  SET TITLEBAR '100'.
ENDMODULE.

MODULE status_0210 OUTPUT.
  SET PF-STATUS 'POPUP'.
  SET TITLEBAR 'POP'.
ENDMODULE.

* PAI

MODULE user_command_0100 INPUT.
  CASE ok_code.
    WHEN space.
      SELECT SINGLE *
             FROM  spfli
             WHERE carrid      = @spfli-carrid
             AND   connid      = @spfli-connid
             INTO  @spfli.
      IF sy-subrc NE 0.
        MESSAGE e005 WITH spfli-carrid spfli-connid.
      ENDIF.
      old_spfli = spfli.
      CLEAR ok_code.
    WHEN 'CANC'.
      CLEAR ok_code.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN 'EXIT'.
      CLEAR ok_code.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN 'BACK'.
      CLEAR ok_code.
      SET SCREEN 0. LEAVE SCREEN.
  ENDCASE.
ENDMODULE.

MODULE user_command_0200 INPUT.
  CASE ok_code.
    WHEN 'SAVE'.
      UPDATE spfli.
      IF sy-subrc = 0.
        MESSAGE s001 WITH spfli-carrid spfli-connid.
      ELSE.
        MESSAGE a002 WITH spfli-carrid spfli-connid.
      ENDIF.
      CLEAR ok_code.
    WHEN 'EXIT'.
      CLEAR ok_code.
      PERFORM safety_check USING rcode.
      IF rcode = 'EXIT'. SET SCREEN 0. LEAVE SCREEN. ENDIF.
    WHEN 'BACK'.
      CLEAR ok_code.
      PERFORM safety_check USING rcode.
      IF rcode = 'EXIT'. SET SCREEN 100. LEAVE SCREEN. ENDIF.
    WHEN 'DELE'.
      MESSAGE w011.
      DELETE FROM spfli
        WHERE carrid = @spfli-carrid
        AND connid = @spfli-connid.
  ENDCASE.
ENDMODULE.

MODULE check_fr_airport INPUT.
  SELECT SINGLE *
         FROM  sairport
         WHERE id = @spfli-airpfrom
         INTO  @sairport.
  IF sy-subrc <> 0.
    MESSAGE e003 WITH spfli-airpfrom.
  ENDIF.
ENDMODULE.

MODULE check_to_airport INPUT.
  SELECT SINGLE *
         FROM  sairport
         WHERE id = @spfli-airpto
         INTO  @sairport.
  IF sy-subrc <> 0.
    MESSAGE e004 WITH spfli-airpto.
  ENDIF.
ENDMODULE.

MODULE exit_0100 INPUT.
  CASE ok_code.
    WHEN 'CANC'.
      CLEAR ok_code.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN 'EXIT'.
      CLEAR ok_code.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN 'BACK'.
      CLEAR ok_code.
      SET SCREEN 0. LEAVE SCREEN.
  ENDCASE.
ENDMODULE.

MODULE exit_0200 INPUT.
  CASE ok_code.
    WHEN 'CANC'.
      CLEAR ok_code.
      SET SCREEN 100. LEAVE SCREEN.
  ENDCASE.
ENDMODULE.

MODULE user_command_0210 INPUT.
  CASE ok_code.
    WHEN 'SAVE'. SET SCREEN 0. LEAVE SCREEN.
    WHEN 'EXIT'. SET SCREEN 0. LEAVE SCREEN.
    WHEN 'CANC'. SET SCREEN 0. LEAVE SCREEN.
  ENDCASE.
ENDMODULE.

MODULE read_text_0100 INPUT.
  SELECT SINGLE *
         FROM scarr
         WHERE carrid = @spfli-carrid
         INTO @scarr.
ENDMODULE.

* Subroutine

FORM safety_check USING rcode.
  LOCAL ok_code.
  rcode = 'EXIT'.
  CHECK spfli NE old_spfli.
  CLEAR ok_code.
  CALL SCREEN 210 STARTING AT 10 5.
  CASE ok_code.
    WHEN 'SAVE'. UPDATE spfli.
    WHEN 'EXIT'.
    WHEN 'CANC'. CLEAR spfli.
  ENDCASE.
ENDFORM.


***  end ***