prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_190100 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2019.03.31'
,p_release=>'19.1.0.00.15'
,p_default_workspace_id=>1239936412967807
,p_default_application_id=>1186
,p_default_owner=>'RVS_TEST'
);
end;
/
prompt --application/shared_components/plugins/item_type/ru_cfrenergo_grpselect
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(2717529220814363)
,p_plugin_type=>'ITEM TYPE'
,p_name=>'RU.CFRENERGO.GRPSELECT'
,p_display_name=>'Grouped Select List'
,p_supported_ui_types=>'DESKTOP'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS:APEX_APPL_PAGE_IG_COLUMNS'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'PROCEDURE render(p_item   IN apex_plugin.t_item',
'                ,p_plugin IN apex_plugin.t_plugin',
'                ,p_param  IN apex_plugin.t_item_render_param',
'                ,p_result IN OUT NOCOPY apex_plugin.t_item_render_result) IS',
'  l_lov        apex_plugin_util.t_column_value_list;',
'  l_group_name VARCHAR2(50 CHAR) := p_item.attribute_01;',
'',
'  c_display_col CONSTANT NUMBER(1) := 1;',
'  c_return_col  CONSTANT NUMBER(1) := 2;',
'  c_grp_col     CONSTANT NUMBER(1) := 3;',
'',
'  FUNCTION get_display_value(p_param_value IN VARCHAR',
'                            ,p_lov         IN apex_plugin_util.t_column_value_list',
'                            ,p_display_col IN NUMBER',
'                            ,p_return_col  IN NUMBER) RETURN VARCHAR2 IS',
'    l_res VARCHAR2(32767);',
'  BEGIN',
'    FOR i IN 1 .. p_lov(p_return_col).count',
'    LOOP',
'      IF (p_lov(p_return_col) (i) = p_param_value) THEN',
'        l_res := p_lov(p_display_col) (i);',
'        EXIT;',
'      END IF;',
'    END LOOP;',
'  ',
'    RETURN l_res;',
'  END;',
'BEGIN',
'  --retrieve data from lov',
'  l_lov := apex_plugin_util.get_data(p_sql_statement  => p_item.lov_definition',
'                                    ,p_min_columns    => 2',
'                                    ,p_max_columns    => 3',
'                                    ,p_component_name => p_item.name);',
'',
'  -- print read only item',
'  IF p_param.is_readonly THEN',
'    apex_plugin_util.print_hidden_if_readonly(p_item_name           => p_item.name',
'                                             ,p_value               => p_param.value',
'                                             ,p_is_readonly         => p_param.is_readonly',
'                                             ,p_is_printer_friendly => p_param.is_printer_friendly);',
'    apex_plugin_util.print_display_only(p_item             => p_item',
'                                       ,p_display_value    => get_display_value(p_param_value => p_param.value',
'                                                                               ,p_lov         => l_lov',
'                                                                               ,p_display_col => c_display_col',
'                                                                               ,p_return_col  => c_return_col)',
'                                       ,p_show_line_breaks => TRUE);',
'  ',
'  ELSE',
'    -- print select list',
'    htp.p(''<select id="'' || p_item.name || ''"',
'      name="'' || apex_plugin.get_input_name_for_item ||',
'          ''" class="selectlist apex-item-select">'');',
'  ',
'    IF (p_item.lov_display_null) THEN',
'      apex_plugin_util.print_option(p_display_value => p_item.lov_null_text',
'                                   ,p_return_value  => p_item.lov_null_value',
'                                   ,p_is_selected   => FALSE',
'                                   ,p_attributes    => p_item.element_option_attributes',
'                                   ,p_escape        => p_item.escape_output);',
'    END IF;',
'  ',
'    -- if Group Name defined',
'    IF l_group_name IS NOT NULL THEN',
'      -- choose groups at first',
'      FOR r_grp IN (SELECT DISTINCT column_value AS group_name',
'                      FROM TABLE(l_lov(3))',
'                     ORDER BY group_name)',
'      LOOP',
'        htp.p(''<optgroup label="'' || r_grp.group_name || ''">'');',
'      ',
'        -- get rows for current group',
'        FOR r_data IN (SELECT display_value',
'                             ,return_value',
'                         FROM (SELECT column_value AS display_value',
'                                     ,rownum       AS rn',
'                                 FROM TABLE(l_lov(c_display_col))) NATURAL',
'                         JOIN (SELECT column_value AS return_value',
'                                    ,rownum       AS rn',
'                                FROM TABLE(l_lov(c_return_col))) NATURAL',
'                         JOIN (SELECT column_value AS group_name',
'                                    ,rownum       AS rn',
'                                FROM TABLE(l_lov(c_grp_col)))',
'                        WHERE group_name = r_grp.group_name)',
'        LOOP',
'          -- print select options',
'          apex_plugin_util.print_option(p_display_value => r_data.display_value',
'                                       ,p_return_value  => r_data.return_value',
'                                       ,p_is_selected   => r_data.return_value =',
'                                                           p_param.value',
'                                       ,p_attributes    => p_item.element_option_attributes',
'                                       ,p_escape        => p_item.escape_output);',
'        END LOOP;',
'      ',
'        htp.p(''</optgroup>'');',
'      END LOOP;',
'    ',
'      -- if Group Name doesn''t defined',
'    ELSE',
'      FOR r_data IN (SELECT display_value',
'                           ,return_value',
'                       FROM (SELECT column_value AS display_value',
'                                   ,rownum       AS rn',
'                               FROM TABLE(l_lov(c_display_col))) NATURAL',
'                       JOIN (SELECT column_value AS return_value',
'                                  ,rownum       AS rn',
'                              FROM TABLE(l_lov(c_return_col))))',
'      LOOP',
'        -- print select options',
'        apex_plugin_util.print_option(p_display_value => r_data.display_value',
'                                     ,p_return_value  => r_data.return_value',
'                                     ,p_is_selected   => r_data.return_value =',
'                                                         p_param.value',
'                                     ,p_attributes    => p_item.element_option_attributes',
'                                     ,p_escape        => p_item.escape_output);',
'      END LOOP;',
'    END IF;',
'  ',
'    htp.p(''</select>'');',
'  ',
'  END IF;',
'END;'))
,p_api_version=>2
,p_render_function=>'render'
,p_standard_attributes=>'VISIBLE:FORM_ELEMENT:SESSION_STATE:READONLY:ESCAPE_OUTPUT:SOURCE:ELEMENT:WIDTH:HEIGHT:ELEMENT_OPTION:LOV:LOV_DISPLAY_NULL:CASCADING_LOV'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_version_identifier=>'1.0'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(2736818778117634)
,p_plugin_id=>wwv_flow_api.id(2717529220814363)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Group Name'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
);
wwv_flow_api.create_plugin_std_attribute(
 p_id=>wwv_flow_api.id(2717727855814381)
,p_plugin_id=>wwv_flow_api.id(2717529220814363)
,p_name=>'LOV'
,p_sql_min_column_count=>2
,p_sql_max_column_count=>3
,p_depending_on_has_to_exist=>true
);
end;
/
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false), p_is_component_import => true);
commit;
end;
/
set verify on feedback on define on
prompt  ...done
