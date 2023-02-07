page 50013 "Indent Line List"
{
    // version RSPL/INDENT/V3/001

    // //sh new functions
    // //SetIndentHeader
    // //IsFirstDocLine
    // //CreateIndentLines
    // //SetPurchHeaderIndent

    AutoSplitKey = false;
    DelayedInsert = false;
    DeleteAllowed = false;
    Editable = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    RefreshOnActivate = true;
    SaveValues = false;
    SourceTable = 50003;
    SourceTableView = SORTING("Entry Type", "Document No.", "Line No.")
                      ORDER(Ascending)
                      WHERE("Entry Type" = FILTER(Indent),
                            Close = CONST(False));
    ApplicationArea = all;
    UsageCategory = Lists;


    layout
    {
        area(content)
        {
            repeater(Control0001)
            {
                field("Entry Type"; "Entry Type")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("Document No."; "Document No.")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = all;
                }
                field(Type; Type)
                {
                    Editable = true;
                    ApplicationArea = all;
                }
                field("No."; "No.")
                {
                    Editable = true;
                    ApplicationArea = all;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = all;
                }
                field("Location Code"; "Location Code")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field(Description; Description)
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field(Category; Category)
                {
                    ApplicationArea = all;
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = all;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = all;
                    Editable = true;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = all;
                }
                field("Requirement Date"; "Requirement Date")
                {
                    ApplicationArea = all;
                }
                field(Remark; Remark)
                {
                    ApplicationArea = all;
                }
                field("End Use"; "End Use")
                {
                    ApplicationArea = all;
                }
                field("PO Qty"; "PO Qty")
                {
                    ApplicationArea = all;
                }
                field(Approved; Approved)
                {
                    ApplicationArea = all;

                    trigger OnValidate();
                    begin
                        IF USer.GET(USERID) THEN
                            IF USer."Indent Approver" = FALSE THEN BEGIN
                                ERROR('You cannot approve the Indent')
                            END ELSE
                                IF Approved = TRUE THEN BEGIN
                                    "Approved By" := USERID;
                                    "Approved Date and Time" := CURRENTDATETIME
                                END ELSE
                                    "Approved By" := '';


                        IF Approved = TRUE THEN
                            TESTFIELD(Remark);

                        RecIH.RESET;
                        RecIH.SETRANGE(RecIH."No.", "Document No.");
                        IF RecIH.FINDFIRST THEN BEGIN
                            IF RecIH.Category = RecIH.Category::Engineering THEN
                                IF Approved = TRUE THEN
                                    TESTFIELD("End Use");
                        END;
                    end;
                }
                field(Status; Status)
                {
                    ApplicationArea = all;

                    trigger OnValidate();
                    begin
                        IF USer.GET(USERID) THEN
                            IF USer."Indent Releaser" = FALSE THEN BEGIN
                                ERROR('You cannot Release the Indent')
                            END;
                    end;
                }
                field("USER ID"; "USER ID")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Item Category Code"; "Item Category Code")
                {
                    ApplicationArea = all;
                }
                field("Material Requisitioned"; "Material Requisitioned")
                {
                    ApplicationArea = all;
                }
                field("Approved Date"; "Approved Date")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Approved By"; "Approved By")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field(Close; Close)
                {

                    ApplicationArea = all;
                    trigger OnValidate();
                    begin
                        CloseOnPush;
                    end;
                }
                field("Comment for Close"; "Comment for Close")
                {
                    Caption = 'Comment for Close';
                    ApplicationArea = all;
                }
                field("Release Date and Time"; "Release Date and Time")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("Approved Date and Time"; "Approved Date and Time")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("Releaser User ID"; "Releaser User ID")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("Outstanding Quantity"; Quantity - "PO Qty")
                {
                    BlankNumbers = BlankZero;
                    BlankZero = true;
                    Caption = 'Outstanding Quantity';
                    NotBlank = false;
                    ApplicationArea = all;

                    trigger OnValidate();
                    begin
                        QuantityPOQtyOnAfterValidate;
                    end;
                }
                field(Closingqty; Closingqty)
                {
                    ApplicationArea = all;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean;
    begin
        IF CloseAction = ACTION::LookupOK THEN
            LookupOKOnPush;
    end;

    var
        PurchHeader: Record 38;
        PurchRcptHeader: Record 120;
        TempIndentLine: Record 50003 temporary;
        GetReceipts: Codeunit 74;
        purchline: Record 39;
        PurcIndnettLine: Record 50003;
        IndentLine: Record 50003;
        IndentLineRec: Record 50003;
        Ok: Boolean;
        USer: Record 91;
        RecIH: Record 50002;

    procedure SetIndentHeader(var PurchHeader2: Record 38);
    begin
        PurchHeader.RESET;
        PurchHeader.SETRANGE(PurchHeader."Document Type", PurchHeader2."Document Type");
        PurchHeader.SETRANGE(PurchHeader."No.", PurchHeader2."No.");
        /*
        PurchHeader.GET(PurchHeader2."Document Type", PurchHeader2."No.");
        PurchHeader.TESTFIELD("Document Type",PurchHeader."Document Type"::Order);
        */

    end;

    local procedure IsFirstDocLine(): Boolean;
    var
        IndentLine: Record 50003;
    begin
        TempIndentLine.RESET;
        TempIndentLine.COPYFILTERS(Rec);
        TempIndentLine.SETRANGE("Document No.", "Document No.");
        IF NOT TempIndentLine.FIND('-') THEN BEGIN
            IndentLine.COPYFILTERS(Rec);
            IndentLine.SETRANGE("Document No.", "Document No.");
            IndentLine.FIND('-');
            TempIndentLine := IndentLine;
            TempIndentLine.INSERT;
        END;
        IF "Line No." = TempIndentLine."Line No." THEN
            EXIT(TRUE);
    end;

    procedure CreateIndentLines(var PurchIndentLine2: Record 50003);
    var
        TransferLine: Boolean;
        DimMgt: Codeunit 408;
    begin
        WITH PurchIndentLine2 DO BEGIN
            SETFILTER(Quantity, '<>0');
            IF FIND('-') THEN BEGIN
                purchline.LOCKTABLE;
                purchline.SETRANGE("Document Type", PurchHeader."Document Type");
                purchline.SETRANGE("Document No.", PurchHeader."No.");
                purchline."Document Type" := PurchHeader."Document Type";
                purchline."Document No." := PurchHeader."No.";

                REPEAT
                    PurcIndnettLine := PurchIndentLine2;
                    PurcIndnettLine.InsertPurchLineFromIndentLine(purchline);
                // DimMgt.MoveTempFromDimToTempToDim(TempFromLineDim,TempToLineDim);
                UNTIL NEXT = 0;
                //  DimMgt.TransferTempToDimToDocDim(TempToLineDim);
            END;
        END;
    end;

    procedure SetPurchHeaderIndent(var PurchHeader2: Record 38);
    begin
        PurchHeader.RESET;
        PurchHeader.SETRANGE(PurchHeader."Document Type", PurchHeader2."Document Type");
        PurchHeader.SETRANGE(PurchHeader."No.", PurchHeader2."No.");
        PurchHeader.SETRANGE(PurchHeader."Location Code", PurchHeader2."Location Code");
        IF PurchHeader.FINDFIRST THEN;
        /*
        PurchHeader.GET(PurchHeader2."Document Type", PurchHeader2."No.");
        PurchHeader.TESTFIELD("Document Type",PurchHeader."Document Type"::Order);
        */
        //PurchHeader.TESTFIELD("Document Type",PurchHeader."Document Type"::Order);

    end;

    procedure ShowLineIndent();
    begin
        ShowLineComments;
    end;

    procedure GetBinContents();
    var
        ILine: Record 50003;
        BIN: Record 7302;
        GETBin: Page 7379;
    begin
        ILine.SETRANGE(ILine."Document No.", "Document No.");
        ILine.SETRANGE(ILine."No.", "No.");
        IF ILine.FINDFIRST THEN BEGIN
            BIN.RESET;
            BIN.SETRANGE(BIN."Item No.", ILine."No.");
            GETBin.SETTABLEVIEW(BIN);
            GETBin.LOOKUPMODE := TRUE;
        END;
        GETBin.EDITABLE(FALSE);
        GETBin.RUN;
    end;

    local procedure QuantityPOQtyOnAfterValidate();
    begin
        MESSAGE('%1', 'T')
    end;

    local procedure CloseOnPush();
    begin
        IF Close = FALSE THEN
            EXIT
        ELSE BEGIN
            Ok := CONFIRM('Do you want to Close?');
            IF Ok = TRUE THEN BEGIN
                Close := TRUE;
                "Close UserID" := USERID;
                MODIFY;
            END ELSE
                Close := FALSE;
            MODIFY;
        END;
    end;

    local procedure LookupOKOnPush();
    begin
        IF (Quantity - "PO Qty") <> 0 THEN BEGIN
            CurrPage.SETSELECTIONFILTER(Rec);
            SetPurchHeaderIndent(PurchHeader);
            CreateIndentLines(Rec);
        END ELSE BEGIN
            ERROR('%1', 'Please select the records having Outstanding Qty');
        END;
    end;
}

