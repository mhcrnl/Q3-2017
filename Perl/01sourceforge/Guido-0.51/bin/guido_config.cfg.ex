<configuration>
	<startup geometry="700x500+40+40" />

  <plugins name="plugins">
    <plugin class_name="ProjectManager" pack="side=left;anchor=nw;fill=y" plugin_name="Project Manager" />
    <plugin class_name="PropertyManager" pack="side=left;anchor=n;expand=1;fill=both" plugin_name="Property Manager" />
    <plugin class_name="Toolbox" pack="side=right;anchor=e;fill=y;expand=1" plugin_name="Toolbox" />
    <plugin class_name="FormBuilder" no_display="1" plugin_name="FormBuilder" />
    <plugin class_name="Executor" no_display="1" plugin_name="Executor" />
  </plugins>

	<plugindata name="ProjectManager" icon_search_path="$ENV{'GUIDOHOME'}/bin/images">
	</plugindata>

	<plugindata name="Toolbox">
    <tool name="Tk::Scrollbar">
      <icon_path></icon_path>
      <defaults></defaults>
    </tool>
    <tool name="Tk::Scale">
      <icon_path></icon_path>
      <defaults></defaults>
    </tool>
    <tool name="Tk::Label">
      <icon_path></icon_path>
      <defaults text="Label" />
      <name_tpl></name_tpl>
    </tool>
    <tool name="Tk::Entry">
      <icon_path></icon_path>
      <defaults></defaults>
    </tool>
    <tool name="Tk::Text">
      <icon_path></icon_path>
      <defaults height="10" width="15" />
      <name_tpl></name_tpl>
    </tool>
    <tool name="Tk::Listbox">
      <icon_path></icon_path>
      <defaults></defaults>
    </tool>
    <tool name="Tk::Button">
      <icon_path></icon_path>
      <defaults text="Button" />
      <name_tpl></name_tpl>
    </tool>
    <tool name="Tk::Checkbutton">
      <icon_path></icon_path>
      <defaults></defaults>
    </tool>
    <tool name="Tk::Frame">
      <icon_path></icon_path>
      <defaults height="100" relief="groove" borderwidth="3" width="100" />
      <name_tpl></name_tpl>
    </tool>
    <tool name="Tk::Radiobutton">
      <icon_path></icon_path>
      <defaults></defaults>
    </tool>
  </plugindata>
  <macros name="macros">
  </macros>  
	<plugindata name="Executor">
		<mimemaps>
			<mimemap suffix=".pm" mimetype="text/perlmodule" />
			<mimemap suffix=".pl" mimetype="text/perl" />
		</mimemaps>
		<mimehandlers>
		</mimehandlers>
	</plugindata>
</configuration>
