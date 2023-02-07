table 50004 "Indent Line Req"
{
    // version RSPL/INDENT/V3/001


    fields
    {
        field(1; "Entry Type"; Option)
        {
            OptionCaption = 'Indent,Posted Indent';
            OptionMembers = Indent;
        }
        field(2; "Document No."; Code[20])
        {
            TableRelation = "Indent Header"."No." WHERE("Entry Type" = FIELD("Entry Type"));
            //This property is currently not supported
            //TestTableRelation = true;
            ValidateTableRelation = true;
        }
        field(3; "Line No."; Integer)
        {
            Editable = false;
        }
        field(4; Date; Date)
        {
            //TableRelation = Table0.Field1987416;

            trigger OnValidate();
            begin
                TestApprove();
            end;
        }
        field(5; Type; Option)
        {
            OptionCaption = '" ,G/L Account,Item,,Fixed Asset,Charge (Item)"';
            OptionMembers = " ","G/L Account",Item,,"Fixed Asset","Charge (Item)";
        }
        field(6; "No."; Code[20])
        {
            TableRelation = IF (Type = CONST(Item)) Item."No."
            ELSE
            IF (Type = CONST("G/L Account")) "G/L Account"."No."
            ELSE
            IF (Type = CONST("Fixed Asset")) "Fixed Asset"."No.";

            trigger OnValidate();
            begin

                TestApprove();
                IF indentheader.GET("Document No.") THEN
                    "Location Code" := indentheader."Location Code";



                CASE Type OF
                    Type::"G/L Account":
                        BEGIN
                            GLAcc.GET("No.");
                            GLAcc.CheckGLAcc;
                            Description := GLAcc.Name;
                            "Unit of Measure Code" := '';
                        END;

                    Type::" ":
                        BEGIN
                            TESTFIELD("No.");
                            Item.GET("No.");
                            Item.TESTFIELD(Blocked, FALSE);
                            Item.TESTFIELD("Inventory Posting Group");
                            Item.TESTFIELD("Gen. Prod. Posting Group");
                            Description := Item.Description;
                            "Description 2" := Item."Description 2";
                            "Unit of Measure Code" := Item."Purch. Unit of Measure";
                        END;


                    Type::Item:
                        BEGIN
                            FA.GET("No.");
                            FA.TESTFIELD(Inactive, FALSE);
                            FA.TESTFIELD(Blocked, FALSE);
                            FA.TESTFIELD("Gen. Prod. Posting Group");
                            Description := FA.Description;
                            "Description 2" := FA."Description 2";
                            "Unit of Measure Code" := '';
                        END;
                END;
            end;
        }
        field(7; "Location Code"; Code[20])
        {
            TableRelation = Location.Code;

            trigger OnValidate();
            begin
                TestApprove();
            end;
        }
        field(8; Quantity; Decimal)
        {

            trigger OnValidate();
            begin
                TestApprove();
                VALIDATE("Line No.");
            end;
        }
        field(10; "PO Qty"; Decimal)
        {
            Editable = false;
            //<<PCPL/NSW/MIG 15July22
            // FieldClass = FlowField;
            // CalcFormula = Sum("Indent Line Req".Quantity WHERE("Entry Type" = FIELD("Document No."),
            //                                                     "PO Qty" = FIELD("Line No."),
            //                                                     "Line No." = FIELD(Type),
            //                                                     Date = FIELD("No."),
            //  
            //>>PCPL/NSW/MIG 15July22                                                   Type = FIELD("Location Code")));

        }
        field(11; Approved; Boolean)
        {

            trigger OnValidate();
            begin

                IF Approved = TRUE THEN
                    IF ("Location Code" = '') THEN
                        ERROR('%1', 'Location Code should not be blank');
                IF (Quantity = 0) THEN
                    ERROR('%1', 'Quanity should not 0');
            end;
        }
        field(12; Description; Text[50])
        {
        }
        field(13; "Description 2"; Text[50])
        {
        }
        field(14; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = IF (Type = CONST(Item)) "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."))
            ELSE
            "Unit of Measure";

            trigger OnValidate();
            var
                UnitOfMeasureTranslation: Record 5402;
            begin
            end;
        }
        field(15; "Requisition Line No."; Integer)
        {
        }
        field(16; "Requisition Templet Name"; Code[30])
        {
        }
        field(17; "Requisition Batch Name"; Code[30])
        {
        }
    }

    keys
    {
        key(Key1; "Entry Type", "Document No.", "Line No.", Type)
        {
        }
        key(Key2; "Location Code", "No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        indentheader: Record 50002;
        indentline: Record 50003;
        Item: Record 27;
        GLAcc: Record 15;
        FA: Record 5600;
        NextLineNo: Integer;
        indentline1: Record 50005;
        outstandqty: Decimal;
        Text000: Label 'Indnet No. %1:';
        Text001: Label 'The program cannot find this purchase line.';

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20]);
    var
        DimMgt: Codeunit 408;
    begin
        /*DimMgt.ValidateDimValueCode(FieldNumber,ShortcutDimCode);
        IF "Line No." <> 0 THEN BEGIN
          DimMgt.SaveDocDim(
            DATABASE::Indent,0,"Document No.",
            "Line No.",FieldNumber,ShortcutDimCode);
          MODIFY;
        END ELSE
          DimMgt.SaveTempDim(FieldNumber,ShortcutDimCode);
        */

    end;

    local procedure TestApprove();
    begin

        IF Approved = TRUE THEN
            ERROR('%1%2', 'No Change in Line for line No', "Line No.");
    end;

    local procedure GetIndentHeader();
    begin
        TESTFIELD(Date);
    end;

    procedure InsertPurchLineFromIndentLine(var PurchLine: Record 39);
    var
        PurchInvHeader: Record 38;
        PurchOrderHeader: Record 38;
        PurchOrderLine: Record 39;
        TempPurchLine: Record 39;
        PurchSetup: Record 312;
        TransferOldExtLines: Codeunit 379;
        ItemTrackingMgt: Codeunit 6500;
        NextLineNo: Integer;
        ExtTextLine: Boolean;
        "**sh": Integer;
        IndentPO: Record 50005;
    begin

        SETRANGE("Document No.", "Document No.");

        TempPurchLine := PurchLine;
        IF PurchLine.FIND('+') THEN
            NextLineNo := PurchLine."Line No." + 10000
        ELSE
            NextLineNo := 10000;

        IndentPO.RESET;
        IndentPO.SETFILTER(IndentPO."Document No.", "Document No.");
        IndentPO.SETRANGE(IndentPO."PO Line No.", "Line No.");
        IndentPO.SETRANGE(IndentPO."Line No.", Type);
        IndentPO.SETFILTER(IndentPO.Date, "No.");
        IndentPO.SETFILTER(IndentPO.Type, "Location Code");
        IF IndentPO.FINDFIRST THEN
            REPEAT
                "PO Qty" += IndentPO."P.O.Qty";
            UNTIL IndentPO.NEXT = 0;


        IF PurchInvHeader."No." <> TempPurchLine."Document No." THEN
            PurchInvHeader.GET(TempPurchLine."Document Type", TempPurchLine."Document No.");

        PurchLine.INIT;
        REPEAT
            PurchLine."Line No." := NextLineNo;
            PurchLine."Document Type" := TempPurchLine."Document Type";
            PurchLine."Document No." := TempPurchLine."Document No.";
            // PurchLine.Type := 2;//PCPL/NSW/MIG 15July22 Code comment add new below new code
            PurchLine.Type := PurchLine.Type::Item;
            PurchLine.VALIDATE(PurchLine."No.", "No.");
            PurchLine.Description := Description;
            PurchLine.Description := "Description 2";
            PurchLine.VALIDATE(PurchLine."Unit of Measure Code", "Unit of Measure Code");
            PurchLine."Location Code" := "Location Code";
            //CALCSUMS("PO Qty");
            CALCFIELDS("PO Qty");
            outstandqty := Quantity - "PO Qty";
            PurchLine.VALIDATE(PurchLine.Quantity, outstandqty);
            PurchLine."Indent No." := "Document No.";
            PurchLine.VALIDATE(PurchLine."Indent Line No.", "Line No.");
            IF outstandqty <> 0 THEN BEGIN
                PurchLine.INSERT;
            END ELSE BEGIN
                EXIT;
            END;

            NextLineNo := NextLineNo + 10000;
        UNTIL PurchLine.NEXT = 0;
    end;
}

