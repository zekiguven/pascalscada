unit pascalscada.security.customized_user_management;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  sysutils,
  pascalscada.security.basic_graphical_user_management;

type

  TCheckUserAndPasswordEvent = procedure(user, pass:String; var aUID:Integer; var ValidUser:Boolean; LoginAction:Boolean) of object;
  TUserStillLoggedEvent      = procedure(var StillLogged:Boolean) of object;
  TGetUserNameAndLogin       = procedure(var UserInfo:String) of object;
  TManageUsersAndGroupsEvent = TNotifyEvent;
  TValidadeSecurityCode      = procedure(const securityCode:String) of object;
  TRegisterSecurityCode      = procedure(const securityCode:String) of object;
  TLogoutEvent               = TNotifyEvent;
  TCanAccessEvent            = procedure(securityCode:String; var CanAccess:Boolean) of object;
  TUIDCanAccessEvent         = procedure(aUID:Integer; securityCode:String; var CanAccess:Boolean) of object;

  { TpSCADACustomizedUserManagement }

  TpSCADACustomizedUserManagement = class(TpSCADABasicGraphicalUserManagement)
  private
    FCheckUserAndPasswordEvent:TCheckUserAndPasswordEvent;
    FGetUserName              :TGetUserNameAndLogin;
    FGetUserLogin             :TGetUserNameAndLogin;
    FManageUsersAndGroupsEvent:TManageUsersAndGroupsEvent;
    FRegisterSecurityCode     :TRegisterSecurityCode;
    FUIDCanAccessEvent        :TUIDCanAccessEvent;
    FValidadeSecurityCode     :TValidadeSecurityCode;
    FCanAccessEvent           :TCanAccessEvent;
    FLogoutEvent              :TLogoutEvent;
  protected
    function  CheckUserAndPassword(User, Pass:String; var UserID:Integer; LoginAction:Boolean):Boolean; override;

    function  GetCurrentUserName:String; override;
    function  GetCurrentUserLogin:String; override;
    function CanAccess(sc: String; aUID: Integer): Boolean; override; overload;
  public
    procedure Logout; override;
    procedure Manage; override;

    //Security codes management
    procedure ValidateSecurityCode(sc:String); override;
    procedure RegisterSecurityCode(sc: String); override;

    function  CanAccess(sc:String):Boolean; override;
  published
    property UID;
    property CurrentUserName;
    property CurrentUserLogin;
    property LoggedSince;

    property LoginRetries;
    property LoginFrozenTime;

    property SuccessfulLogin;
    property FailureLogin;
  published
    property OnCheckUserAndPass    :TCheckUserAndPasswordEvent read FCheckUserAndPasswordEvent write FCheckUserAndPasswordEvent;
    property OnGetUserName         :TGetUserNameAndLogin       read FGetUserName               write FGetUserName;
    property OnGetUserLogin        :TGetUserNameAndLogin       read FGetUserLogin              write FGetUserLogin;
    property OnManageUsersAndGroups:TManageUsersAndGroupsEvent read FManageUsersAndGroupsEvent write FManageUsersAndGroupsEvent;
    property OnValidadeSecurityCode:TValidadeSecurityCode      read FValidadeSecurityCode      write FValidadeSecurityCode;
    property OnRegisterSecurityCode:TRegisterSecurityCode      read FRegisterSecurityCode      write FRegisterSecurityCode;
    property OnCanAccess           :TCanAccessEvent            read FCanAccessEvent            write FCanAccessEvent;
    property OnUIDCanAccess        :TUIDCanAccessEvent         read FUIDCanAccessEvent         write FUIDCanAccessEvent;
    property OnLogout              :TLogoutEvent               read FLogoutEvent               write FLogoutEvent;
  end;

implementation

{ TpSCADACustomizedUserManagement }

function TpSCADACustomizedUserManagement.CheckUserAndPassword(User,
  Pass: String; var UserID: Integer; LoginAction: Boolean): Boolean;
begin
  Result:=false;
  try
    if Assigned(FCheckUserAndPasswordEvent) then
      FCheckUserAndPasswordEvent(user,Pass,UserID,Result,LoginAction);
  except
    Result:=false;
  end;
end;

function TpSCADACustomizedUserManagement.GetCurrentUserName: String;
begin
  Result:='';
  if FLoggedUser then
    try
      if Assigned(FGetUserName) then
        FGetUserName(Result);
    except
      Result:='';
    end;
end;

function TpSCADACustomizedUserManagement.GetCurrentUserLogin: String;
begin
  Result:='';
  if FLoggedUser then
    try
      if Assigned(FGetUserLogin) then
        FGetUserLogin(Result);
    except
      Result:='';
    end;
end;

function TpSCADACustomizedUserManagement.CanAccess(sc: String; aUID: Integer
  ): Boolean;
begin
  Result:=(Trim(sc)='');
  if aUID>=0 then
    try
      if Assigned(FUIDCanAccessEvent) then
        FUIDCanAccessEvent(aUID,sc,Result);
    except
      Result:=(Trim(sc)='');
    end;
end;

procedure TpSCADACustomizedUserManagement.Logout;
begin
  inherited Logout;
  if Assigned(FLogoutEvent) then
    try
      FLogoutEvent(self);
    except
    end;
end;

procedure TpSCADACustomizedUserManagement.Manage;
begin
  if Assigned(FManageUsersAndGroupsEvent) then
    FManageUsersAndGroupsEvent(Self);
end;

procedure TpSCADACustomizedUserManagement.ValidateSecurityCode(sc: String);
begin
  if Assigned(FValidadeSecurityCode) then
    FValidadeSecurityCode(sc);
end;

procedure TpSCADACustomizedUserManagement.RegisterSecurityCode(sc: String);
begin
  if Assigned(FRegisterSecurityCode) then
    FRegisterSecurityCode(sc);
end;

function TpSCADACustomizedUserManagement.CanAccess(sc: String): Boolean;
begin
  Result:=(Trim(sc)='');
  if FLoggedUser then
    try
      if Assigned(FCanAccessEvent) then
        FCanAccessEvent(sc,Result);
    except
      Result:=(Trim(sc)='');
    end;
end;

end.

