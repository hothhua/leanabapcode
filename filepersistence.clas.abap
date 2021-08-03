TABLES: zesa_issue_hdr.
PARAMETER: id LIKE zesa_issue_hdr-id OBLIGATORY DEFAULT 1.
PARAMETER: ifile TYPE file_table-filename OBLIGATORY
DEFAULT 'c:issue.xml'.

*———————————————————————-*
* VARIABLES                                                            *
*———————————————————————-*
****List of possible filenames.
DATA: ifile_tab TYPE filetable.
****Filetable work area
DATA: ifile_tab_line LIKE LINE OF ifile_tab.
****File Open Return Code
DATA: rc TYPE i.
****Temp File name for function module call.
DATA: ifilename TYPE string.
DATA: issue TYPE REF TO zcl_es_asap_issue_object.
*———————————————————————-*
* SELECTION SCREEN – VALUE REQUES FOR FILENAME                         *
*———————————————————————-*
AT SELECTION-SCREEN   ON VALUE-REQUEST FOR ifile.
  DATA: window_title TYPE string.
  DATA: path TYPE string.
  DATA: filename TYPE string.
  DATA: fullpath TYPE string.
  MOVE 'Download XML File Location'(001) TO window_title.
  CALL METHOD cl_gui_frontend_services=>file_save_dialog
    EXPORTING
      window_title      = window_title
      default_extension = 'xml'
    CHANGING
      filename          = filename
      path              = path
      fullpath          = fullpath
    EXCEPTIONS
      cntl_error        = 1
      error_no_gui      = 2
      OTHERS            = 3.
  IF sy-subrc <> 0.
  ELSE.
    MOVE fullpath TO ifile.
  ENDIF.

START-OF-SELECTION.
  MOVE ifile TO ifilename.
  CREATE OBJECT issue
    EXPORTING
      id          = id
      create_mode = abap_false.
  DATA: g_ixml           TYPE REF TO if_ixml,
        g_stream_factory TYPE REF TO if_ixml_stream_factory,
        xslt_err         TYPE REF TO cx_xslt_exception,
        g_encoding       TYPE REF TO if_ixml_encoding,
        ostream          TYPE REF TO if_ixml_ostream.
  CONSTANTS:  line_length TYPE i VALUE 4096.
  TYPES: line_t(line_length) TYPE x,
         table_t             TYPE STANDARD TABLE OF line_t.
  DATA: restab TYPE table_t.
  CONSTANTS:
* encoding for download of XML files
  encoding     TYPE string VALUE 'utf-8'.
  DATA: ressize TYPE i.

  TRY.
      g_ixml = cl_ixml=>create( ).
      g_stream_factory = g_ixml->create_stream_factory( ).
      g_encoding = g_ixml->create_encoding(
            character_set = encoding
            byte_order = 0 ).
      REFRESH restab.
      ostream = g_stream_factory->create_ostream_itable( table = restab ).
      ostream->set_encoding( encoding = g_encoding ).
      CALL TRANSFORMATION id_indent
        SOURCE
          asap_issue = issue
        RESULT XML restab.
          ressize = ostream->get_num_written_raw( ).
    CATCH cx_xslt_exception INTO xslt_err.
      DATA: s TYPE string.
      s = xslt_err->get_text( ).
  ENDTRY.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      bin_filesize = ressize
      filename     = ifilename
      filetype     = 'BIN'
    TABLES
      data_tab     = restab
    EXCEPTIONS
      OTHERS       = 1.
  CALL METHOD cl_gui_frontend_services=>execute
    EXPORTING
      document               = ifilename
*     APPLICATION            =
*     PARAMETER              =
*     DEFAULT_DIRECTORY      =
*     MAXIMIZED              =
*     MINIMIZED              =
*     SYNCHRONOUS            =
    EXCEPTIONS
      cntl_error             = 1
      error_no_gui           = 2
      bad_parameter          = 3
      file_not_found         = 4
      path_not_found         = 5
      file_extension_unknown = 6
      error_execute_failed   = 7
      OTHERS                 = 8.
