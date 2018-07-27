unit BooksControllerU;

interface

uses MVCFramework, BooksModuleU, MVCFramework.Commons;

type

  [MVCPath('/books')]
  TBooksController = class(TMVCController)
  private
    FBookModule: TBookModule;
  protected
    procedure OnAfterAction(Context: TWebContext;
      const AActionNAme: string); override;
    procedure OnBeforeAction(Context: TWebContext; const AActionNAme: string;
      var Handled: Boolean); override;
  public
    [MVCPath]
    [MVCHTTPMethod([httpGET])]
    procedure GetBooks;
    [MVCPath('/($id)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetBookByID(id: Integer);
    [MVCPath]
    [MVCHTTPMethod([httpPOST])]
    [MVCConsumes('application/json')]
    procedure CreateBook;
    [MVCPath('/($id)')]
    [MVCHTTPMethod([httpPUT])]
    [MVCConsumes('application/json')]
    procedure UpdateBook(id: Integer);
    [MVCPath('/($id)')]
    [MVCHTTPMethod([httpDELETE])]
    procedure DeleteBook(id: Integer);
  end;

implementation

uses
  BookBO, SysUtils, System.JSON, System.Math, MVCFramework.Logger, Data.DB,
  MVCFramework.Serializer.Commons;

procedure TBooksController.CreateBook;
var
  Book: TBook;
begin
  Book := Context.Request.BodyAs<TBook>;
  FBookModule.CreateBook(Book);
  Context.Response.Location := '/books/' + Book.ID.ToString;
  Render(201, 'Book created');
end;

procedure TBooksController.UpdateBook(id: Integer);
var
  Book: TBook;
begin
  Book := Context.Request.BodyAs<TBook>;
  try
    Book.ID := id;
    FBookModule.UpdateBook(Book);
    Render(200, 'Book updated');
  finally
    Book.Free;
  end;
end;

procedure TBooksController.DeleteBook(id: Integer);
var
  BookID: Integer;
begin
  BookID := id;
  FBookModule.DeleteBook(BookID);
  MVCFramework.Logger.LogI('Requested delete for book with id ' +
    BookID.ToString);
  Render(204, 'Book deleted');
end;

procedure TBooksController.GetBookByID(id: Integer);
var
  BookDS: TDataSet;
begin
  MVCFramework.Logger.LogI('Requested book with id ' + id.ToString);
  BookDS := FBookModule.GetBookByID(id);
  Render(BookDS, False, dstSingleRecord);
end;

procedure TBooksController.GetBooks;
var
  BooksDS: TDataSet;
begin
  MVCFramework.Logger.LogI('Books list request');
  BooksDS := FBookModule.GetBooks;
  Render(BooksDS, False, dstAllRecords);
end;

procedure TBooksController.OnAfterAction(Context: TWebContext;
  const AActionNAme: string);
begin
  inherited;
  FBookModule.Free;
end;

procedure TBooksController.OnBeforeAction(Context: TWebContext;
  const AActionNAme: string; var Handled: Boolean);
begin
  inherited;
  FBookModule := TBookModule.Create(nil);
end;

end.
