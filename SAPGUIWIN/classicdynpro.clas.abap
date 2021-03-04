
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
