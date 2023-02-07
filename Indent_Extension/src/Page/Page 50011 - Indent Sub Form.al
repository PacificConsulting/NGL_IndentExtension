page 50011 "Indent Sub Form"
{
    // version RSPL/INDENT/V3/001,PCPL-JOB0001

    // //sh new functions
    // //SetIndentHeader
    // //IsFirstDocLine
    // //CreateIndentLines
    // //SetPurchHeaderIndent

    AutoSplitKey = true;
    DelayedInsert = true;
    DeleteAllowed = true;
    Editable = true;
    InsertAllowed = true;
    LinksAllowed = false;
    ModifyAllowed = true;
    MultipleNewLines = true;
    PageType = ListPart;
    SaveValues = true;
    SourceTable = 50003;
    SourceTableView = SORTING("Entry Type", "Document No.", "Line No.")
                      ORDER(Ascending)
                      WHERE("Entry Type" = FILTER(Indent),
                            Close = CONST(false));

    layout
    {
        area(content)
        {
            repeater(Control001)
            {
                field(Type; Type)
                {
                    Editable = true;
                    ApplicationArea = all;
                }
                field("Requisition Batch Name"; "Requisition Batch Name")
                {
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
                field("Product Group Code"; "Product Group Code")
                {
                    Visible = false;
                    ApplicationArea = all;
                }
                field(Description; Description)
                {
                    ApplicationArea = all;

                    trigger OnValidate();
                    begin
                        IF "No." = '' THEN
                            ERROR('Please Select Type in Indent Line');
                    end;
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = all;

                    trigger OnValidate();
                    begin
                        IF "No." = '' THEN
                            ERROR('Please Select Type in Indent Line');
                    end;
                }
                field("Requirement Date"; "Requirement Date")
                {
                    ApplicationArea = all;
                }
                field("FA Component Category"; "FA Component Category")
                {
                    ApplicationArea = all;
                }
                field("Description 3"; "Description 3")
                {
                    ApplicationArea = all;
                    Visible = false;

                    trigger OnValidate();
                    begin
                        IF "No." = '' THEN
                            ERROR('Please Select Type in Indent Line');
                    end;
                }
                field("Material Requisitioned"; "Material Requisitioned")
                {
                    ApplicationArea = all;
                    Visible = false;

                    trigger OnValidate();
                    begin
                        IF "No." = '' THEN
                            ERROR('Please Select Type in Indent Line');
                    end;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = all;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = all;
                    Editable = true;
                }
                field("PO Qty"; "PO Qty")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Outstanding Quantity"; Quantity - "PO Qty")
                {
                    ApplicationArea = all;
                    BlankNumbers = BlankZero;
                    BlankZero = true;
                    Caption = 'Outstanding Quantity';
                    NotBlank = false;

                    trigger OnValidate();
                    begin
                        QuantityPOQtyOnAfterValidate;
                    end;
                }
                field(Remark; Remark)
                {
                    ApplicationArea = all;
                }
                field(Comment; Comment)
                {
                    ApplicationArea = all;
                }
                field(Approved; Approved)
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
                field("USER ID"; "USER ID")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Outstanding True"; "Outstanding True")
                {
                    ApplicationArea = all;
                    Visible = false;
                }
                field(Status; Status)
                {
                    ApplicationArea = all;
                }
                field("Line No."; IndentLine."Line No.")
                {
                    ApplicationArea = all;
                }
                field(Closingqty; Closingqty)
                {
                    ApplicationArea = all;
                }
                field("Indent Closing Date"; "Indent Closing Date")
                {
                    ApplicationArea = all;
                }
                field("Main Category"; "Main Category")
                {
                    ApplicationArea = all;
                }
                field("FA Sub Category"; "FA Sub Category")
                {
                    ApplicationArea = all;
                }
                field("Job No."; "Job No.")
                {
                    ApplicationArea = all;
                }
                field("Job Task No."; "Job Task No.")
                {
                    ApplicationArea = all;
                }
                field("Job Planning Line No."; "Job Planning Line No.")
                {
                    ApplicationArea = all;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("&Line")
            {
                CaptionML = ENU = '&Line',
                            ENN = '&Line';
                Image = Line;

                action("Split Lines")
                {
                    ApplicationArea = all;

                    trigger OnAction();
                    var
                        recIL: Record 50003;
                        IndentLine: Record 50003;
                        NoOfIndLines: Integer;
                        Text001: Label 'PO Qty must be Zero to split Indent Lines.';
                        Text002: Label 'Do you want to split the Indent line and use it to create Indent lines\for the other Indent items with divided amounts?';
                        NextLine: Integer;
                        vQty: Decimal;
                    begin
                        CALCFIELDS("PO Qty");
                        IF "PO Qty" = 0 THEN BEGIN
                            recIL.RESET;
                            recIL.SETRANGE("Document No.", "Document No.");
                            recIL.SETRANGE("Line No.", "Line No.");
                            IF CONFIRM(Text002) THEN BEGIN
                                IndentLine.RESET;
                                IndentLine.SETRANGE("Document No.", "Document No.");
                                IndentLine.SETRANGE("Line No.", "Line No.");
                                IF IndentLine.FINDLAST THEN
                                    NextLine := IndentLine."Line No." + 1
                                ELSE
                                    NextLine := 1000;
                                vQty := ROUND(Quantity / 2, 0.01);
                                IF recIL.FIND('-') THEN BEGIN
                                    CLEAR(IndentLine);
                                    IndentLine.INIT;
                                    IndentLine."Entry Type" := "Entry Type";
                                    IndentLine."Document No." := "Document No.";
                                    IndentLine."Line No." := NextLine;
                                    IndentLine.INSERT(TRUE);
                                    IndentLine.TRANSFERFIELDS(Rec, FALSE);
                                    IndentLine.VALIDATE(Quantity, vQty);
                                    IndentLine.MODIFY(TRUE);
                                    Quantity := ROUND(Quantity / 2, 0.01);
                                    MODIFY;
                                END;
                            END;
                        END ELSE
                            ERROR(Text001);
                    end;
                }
            }
        }
    }

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
                //        DimMgt.MoveTempFromDimToTempToDim(TempFromLineDim,TempToLineDim);
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
}

