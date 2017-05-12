unit EmailOrdering.Controllers.MainControllerInt;

interface

uses
  IdMessage, Wddc.Inventory.Order, EmailOrdering.Models.EmailMsg;

type
  IMainController = Interface(IInterface)
    procedure NewOrder(const msg: TEmailMsg);
    procedure ShowMessageForm();
    procedure OpenSuccess();
    procedure OpenFailure();
    procedure OpenConfirmation(orderId: integer);
    procedure ClearOrderLog();
    procedure UpdateConfig();
    procedure OpenSettingsForm();
    procedure SetupEmailServer();
    procedure StopEmailServer();
    procedure ShowHelp();
  End;

implementation

end.
