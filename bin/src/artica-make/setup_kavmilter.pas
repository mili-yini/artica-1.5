unit setup_kavmilter;
{$MODE DELPHI}
//{$mode objfpc}{$H+}
{$LONGSTRINGS ON}
//ln -s /usr/lib/libmilter/libsmutil.a /usr/local/lib/libsmutil.a
//apt-get install libmilter-dev
interface

uses
  Classes, SysUtils,strutils,RegExpr in 'RegExpr.pas',
  unix,IniFiles,setup_libs,distridetect,
  install_generic,logs,obm,zsystem;

  type
  tsetup_kavmilter=class


private
     libs:tlibs;
     distri:tdistriDetect;
     install:tinstall;
   source_folder,cmd:string;
   webserver_port:string;
   artica_admin:string;
   artica_password:string;
   ldap_suffix:string;
   mysql_server:string;
   mysql_admin:string;
   mysql_password:string;
   ldap_server:string;




public
      constructor Create();
      procedure Free;
      procedure xinstall();
      procedure xremove();
      procedure kav4lms_xinstall();
END;

implementation

constructor tsetup_kavmilter.Create();
begin
distri:=tdistriDetect.Create();
libs:=tlibs.Create;
install:=tinstall.Create;
source_folder:='';
webserver_port:=install.lighttpd.LIGHTTPD_LISTEN_PORT();
   artica_admin:=install.openldap.get_LDAP('admin');
   artica_password:=install.openldap.get_LDAP('password');
   ldap_suffix:=install.openldap.get_LDAP('suffix');
   ldap_server:=install.openldap.get_LDAP('server');
   mysql_server:=install.SYS.MYSQL_INFOS('mysql_server');
   mysql_admin:=install.SYS.MYSQL_INFOS('database_admin');
   mysql_password:=install.SYS.MYSQL_INFOS('password');
end;
//#########################################################################################
procedure tsetup_kavmilter.Free();
begin
  libs.Free;
end;
//#########################################################################################
procedure tsetup_kavmilter.xinstall();
var
source_folder:string;
logs:Tlogs;
SYS:TSystem;
zobm:tobm;
begin

 logs:=Tlogs.Create;
 SYS:=Tsystem.Create();



if DirectoryExists(ParamStr(2)) then source_folder:=ParamStr(2);
install.INSTALL_STATUS('APP_KAVMILTER',10);

install.INSTALL_PROGRESS('APP_KAVMILTER','{downloading}');

if FileExists('/home/artica/packages/kav4milter-5.6.20.2.tgz') then begin
   ForceDirectories('/tmp/kavm');
   fpsystem('/bin/tar -xf /home/artica/packages/kav4milter-5.6.20.2.tgz -C /tmp/kavm/');
   source_folder:='/tmp/kavm';
end;


if not FileExists('/opt/kav/5.6/kavmilter/bin/kavmilter') then begin
   if length(source_folder)=0 then source_folder:=libs.COMPILE_GENERIC_APPS('kavmilter');

   if not DirectoryExists(source_folder) then begin
     writeln('Install kavmilter failed...');
     install.INSTALL_STATUS('APP_KAVMILTER',110);
     exit;
   end;
  install.INSTALL_STATUS('APP_KAVMILTER',30);
  writeln('Install kavmilter extracted on "'+source_folder+'"');
  install.INSTALL_STATUS('APP_KAVMILTER',50);
  forcedirectories('/etc/kav/5.6/kavmilter');
  forcedirectories('/opt/kav/5.6/kavmilter');
  forcedirectories('/var/db/kav/5.6/kavmilter/backup');
  ForceDirectories('/var/log/kav/5.6/kavmilter');
  install.INSTALL_PROGRESS('APP_KAVMILTER','{installing}');
  fpsystem('/bin/cp -rfv '+source_folder+'/etc/kav/5.6/kavmilter/* /etc/kav/5.6/kavmilter/');
  fpsystem('/bin/cp -rfv '+source_folder+'/opt/kav/5.6/kavmilter/* /opt/kav/5.6/kavmilter/');
  fpsystem('/bin/cp -rfv '+source_folder+'/usr/lib/* /usr/lib/');
  fpsystem('/bin/cp -rfv '+source_folder+'/var/db/kav/5.6/kavmilter/* /var/db/kav/5.6/kavmilter/');
end;
  install.INSTALL_STATUS('APP_KAVMILTER',60);

  fpsystem('/bin/chmod 777 /opt/kav/5.6/kavmilter/bin/kavmilter-setup.sh');
  fpsystem('/opt/kav/5.6/kavmilter/bin/kavmilter-setup.sh -add-user');
  fpsystem('/opt/kav/5.6/kavmilter/bin/kavmilter-setup.sh -trial-key /usr/share/artica-postfix/bin/install/AVM.key');
  fpsystem('/bin/chown -R root:kav /var/db/kav/5.6/kavmilter');
  fpsystem('/bin/chown root:kav /var/log/kav/5.6/kavmilter');
  fpsystem('/bin/chmod 0775 /var/log/kav/5.6/kavmilter');
  fpsystem('/bin/chmod 0775 /var/db/kav/5.6/kavmilter/run');
  fpsystem('/bin/chmod 0770 /var/db/kav/5.6/kavmilter/tmp');
  fpsystem('/bin/chmod 0770 /var/db/kav/5.6/kavmilter/licenses');
  fpsystem('/bin/chmod 0770 /var/db/kav/5.6/kavmilter/bases/backup');
  fpsystem('/bin/chmod 0775 /var/db/kav/5.6/kavmilter/mibs');
  fpsystem('/bin/chown root:kav /opt/kav/5.6/kavmilter/bin/kavmilter');
  fpsystem('/bin/chmod 0755 /opt/kav/5.6/kavmilter/bin/kavmilter');
  fpsystem('/bin/chown root:kav /etc/kav/5.6/kavmilter/init.d/kavmilterd');
  fpsystem('/bin/chmod 0755 /etc/kav/5.6/kavmilter/init.d/kavmilterd');
  fpsystem('/bin/chown root:kav /usr/lib/libkavcommon.so.*');
  fpsystem('/bin/chown root:kav /usr/lib/libkavsnmp.so.*');
  fpsystem('/bin/chmod 0644 /usr/lib/libkavcommon.so.*');
  fpsystem('/bin/chmod 0644 /usr/lib/libkavsnmp.so.*');
  fpsystem('/bin/ln -s -f /etc/kav/5.6/kavmilter/init.d/kavmilterd /etc/init.d/kavmilterd');
  fpsystem('/bin/chown -R root:kav /opt/kav/5.6/kavmilter');
  fpsystem('/bin/chmod 0755 /opt/kav/5.6/kavmilter/bin/kavmilter-setup.sh');
  fpsystem('/opt/kav/5.6/kavmilter/bin/kavmilter-setup.sh -default-domains 1> /dev/null 2> /dev/null');
  fpsystem('/opt/kav/5.6/kavmilter/bin/kavmilter-setup.sh -add-service 1> /dev/null 2> /dev/null');
  install.INSTALL_STATUS('APP_KAVMILTER',100);
  install.INSTALL_PROGRESS('APP_KAVMILTER','{installed}');
  writeln('success');
  if FileExists('/home/artica/packages/kav4milter-5.6.20.2.tgz') then fpsystem('/bin/rm -f /home/artica/packages/kav4milter-5.6.20.2.tgz');
  if DirectoryExists('/tmp/kavm') then fpsystem('/bin/rm -rf /tmp/kavm');
end;
//#########################################################################################
procedure tsetup_kavmilter.xremove();
begin
fpsystem('/etc/init.d/kavmilterd stop >/dev/null 2>&1');
fpsystem('/opt/kav/5.6/kavmilter/bin/kavmilter-setup.sh -del-service');
fpsystem('/bin/rm -rf /opt/kav/5.6/kavmilter >/dev/null 2>&1');
fpsystem('/bin/rm  /etc/init.d/kavmilterd >/dev/null 2>&1');
fpsystem('rm -rf /var/db/kav/5.6/kavmilter >/dev/null 2>&1');
fpsystem('rm -rf /etc/kav/5.6 >/dev/null 2>&1');
end;
//#########################################################################################
procedure tsetup_kavmilter.kav4lms_xinstall();
var
source_folder:string;
logs:Tlogs;
SYS:TSystem;
zobm:tobm;
begin

 logs:=Tlogs.Create;
 SYS:=Tsystem.Create();



if DirectoryExists(ParamStr(2)) then source_folder:=ParamStr(2);
install.INSTALL_STATUS('APP_KAVMILTER',10);
install.INSTALL_PROGRESS('APP_KAVMILTER','{downloading}');
source_folder:=libs.COMPILE_GENERIC_APPS('kav4lms');
install.INSTALL_STATUS('APP_KAVMILTER',30);
writeln('Install kavmilter extracted on "'+source_folder+'"');
install.INSTALL_STATUS('APP_KAVMILTER',50);
forcedirectories('/etc/opt/kaspersky/kav4lms');
forcedirectories('/opt/kav/5.6/kavmilter');
forcedirectories('/opt/kaspersky/kav4lms');
ForceDirectories('/var/log/kaspersky/kav4lms');
ForceDirectories('/var/opt/kaspersky/kav4lms');
ForceDirectories('/var/run/kav4lms');
  source_folder:=ExtractFilePath(source_folder);
   if not DirectoryExists(source_folder) then begin
     writeln('Install kavmilter failed...');
     install.INSTALL_STATUS('APP_KAVMILTER',110);
     exit;
   end;


  xremove();

  install.INSTALL_PROGRESS('APP_KAVMILTER','{installing}');
  fpsystem('/bin/cp -rfv '+source_folder+'etc/init.d/* /etc/init.d/');
  fpsystem('/bin/cp -rfv '+source_folder+'etc/opt/* /etc/opt/');
  fpsystem('/bin/cp -rfv '+source_folder+'opt/* /opt/');
  fpsystem('/bin/cp -rfv '+source_folder+'var/* /var/');


  install.INSTALL_STATUS('APP_KAVMILTER',60);

  fpsystem('/bin/chmod 777 /opt/kaspersky/kav4lms/bin/kav4lms-setup.sh');
  fpsystem('/opt/kaspersky/kav4lms/bin/kav4lms-setup.sh --install-services');
  fpsystem('/opt/kaspersky/kav4lms/bin/kav4lms-setup.sh --add-components-info');
  fpsystem('/opt/kaspersky/kav4lms/bin/kav4lms-setup.sh --register-key=/usr/share/artica-postfix/bin/install/MLX_00BD2B2E_081231.key');
  fpsystem('/opt/kaspersky/kav4lms/bin/kav4lms-setup.sh --switch-credentials=postfix,postfix');
  install.INSTALL_STATUS('APP_KAVMILTER',100);
  install.INSTALL_PROGRESS('APP_KAVMILTER','{installed}');
  fpsystem('/etc/init.d/artica-postfix restart kav4lms');
  writeln('success');
end;




end.
