page 50009 "Indent History"
{
    // version RSPL/INDENT/V3/001

    // //sh new functions
    // //SetIndentHeader
    // //IsFirstDocLine
    // //CreateIndentLines
    // //SetPurchHeaderIndent

    AutoSplitKey = true;
    DelayedInsert = true;
    DeleteAllowed = true;
    Editable = false;
    InsertAllowed = true;
    ModifyAllowed = true;
    PageType = Card;
    SaveValues = true;
    SourceTable = 50003;
    SourceTableView = SORTING("Entry Type", "Document No.", "Line No.")
                      ORDER(Ascending)
                      WHERE("Entry Type" = FILTER(Indent),
                            Close = FILTER(true));
    ApplicationArea = all;
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Control001)
            {
                field("Entry Type"; "Entry Type")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field(Date; Date)
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("Document No."; "Document No.")
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
                    ApplicationArea = all;
                    Editable = false;
                }
                field(Description; Description)
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = all;
                }
                field("Item Category Code"; "Item Category Code")
                {
                    ApplicationArea = all;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = all;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = all;
                    Editable = true;
                }
                field("Requirement Date"; "Requirement Date")
                {
                    ApplicationArea = all;
                }
                field(Approved; Approved)
                {
                    ApplicationArea = all;
                }
                field("Material Requisitioned"; "Material Requisitioned")
                {
                    ApplicationArea = all;
                }
                field("PO Qty"; "PO Qty")
                {
                    ApplicationArea = all;
                }
                field(Remark; Remark)
                {
                    ApplicationArea = all;
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
                field("USER ID"; "USER ID")
                {
                    ApplicationArea = all;
                }
                field("Approved Date"; "Approved Date")
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
                //DimMgt.MoveTempFromDimToTempToDim(TempFromLineDim,TempToLineDim);
                UNTIL NEXT = 0;
                // DimMgt.TransferTempToDimToDocDim(TempToLineDim);
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

