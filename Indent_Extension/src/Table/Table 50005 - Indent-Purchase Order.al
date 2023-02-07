table 50005 "Indent-Purchase Order"
{
    // version RSPL/INDENT/V3/001

    // CODE            NAME          DATE            DESCRIPTION
    // --------------------------------------------------------------------------------
    // 
    // ROBOSOFT-V001   Abhinav       19-01-2012      Update Outstanding True for Equal Qty

    DrillDownPageID = 50014;
    LookupPageID = 50014;

    fields
    {
        field(1; "Document No."; Code[20])
        {
            TableRelation = "Indent Header";
        }
        field(2; Date; Date)
        {
        }
        field(3; Type; Option)
        {
            OptionCaption = '" ,G/L Account,Item,,Fixed Asset,Charge (Item)"';
            OptionMembers = " ","G/L Account",Item,,"Fixed Asset","Charge (Item)";
        }
        field(4; "No."; Code[20])
        {
            TableRelation = IF (Type = CONST(Item)) Item."No."
            ELSE
            IF (Type = CONST("G/L Account")) "G/L Account"."No."
            ELSE
            IF (Type = CONST("Fixed Asset")) "Fixed Asset"."No.";
        }
        field(5; "Location Code"; Code[20])
        {
            TableRelation = Location.Code;
        }
        field(6; "P.O.No."; Code[20])
        {
            Editable = false;
            TableRelation = "Purchase Header"."No." WHERE("Document Type" = CONST(Order));
        }
        field(7; "P.O.Date"; Date)
        {
            Editable = false;
        }
        field(8; "P.O.Qty"; Decimal)
        {
            Editable = false;

            trigger OnValidate();
            begin
                //ROBOSOFT-V001-----Start


                CLEAR(Qty1);
                RecPurchLine.RESET;
                RecPurchLine.SETRANGE(RecPurchLine."Document No.", "Document No.");
                RecPurchLine.SETRANGE(RecPurchLine.Type, Type);
                RecPurchLine.SETRANGE(RecPurchLine."No.", "No.");
                RecPurchLine.SETRANGE(RecPurchLine."Location Code", "Location Code");
                RecPurchLine.SETRANGE(RecPurchLine."Line No.", "Line No.");
                IF RecPurchLine.FINDSET THEN
                    REPEAT
                        Qty1 += RecPurchLine."P.O.Qty";
                    UNTIL RecPurchLine.NEXT = 0;



                RecIndentLine.RESET;
                RecIndentLine.SETRANGE(RecIndentLine."Entry Type", RecIndentLine."Entry Type"::Indent);
                RecIndentLine.SETRANGE(RecIndentLine."Document No.", "Document No.");
                RecIndentLine.SETRANGE(RecIndentLine."Line No.", "Line No.");
                RecIndentLine.SETRANGE(RecIndentLine.Type, Type);
                RecIndentLine.SETRANGE(RecIndentLine."No.", "No.");
                IF RecIndentLine.FINDFIRST THEN BEGIN
                    IF RecIndentLine.Quantity = Qty1 THEN BEGIN
                        RecIndentLine."Outstanding True" := TRUE;
                        RecIndentLine.MODIFY;
                    END;
                END;


                //MESSAGE('%1,%2,%3',Qty1,RecIndentLine.Quantity,RecIndentLine."Outstanding True");
                //ROBOSOFT-V001-----End
            end;
        }
        field(9; "PO Line No."; Integer)
        {
            Editable = false;
        }
        field(10; "Line No."; Integer)
        {
        }
        field(11; "OutStanding True"; Boolean)
        {
        }
        field(12; "Vendor Name"; Text[50])
        {
            CalcFormula = Lookup("Purchase Header"."Buy-from Vendor Name" WHERE("No." = FIELD("P.O.No.")));
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Document No.", Type, "No.", "Line No.", "Location Code", "P.O.No.", "PO Line No.")
        {
            SumIndexFields = "P.O.Qty";
        }
    }

    fieldgroups
    {
    }

    var
        IndentLine: Record 50003;
        Qty: Integer;
        RecIndentLine: Record 50003;
        RecPurchLine: Record 50005;
        Qty1: Decimal;

    procedure InsertPurchLineFromIndentLine(var PurchLine: Record 39);
    begin
        /*
        SETRANGE("Document No.","Document No.");
        
        TempPurchLine := PurchLine;
        IF PurchLine.FIND('+') THEN
          NextLineNo := PurchLine."Line No." + 10000
        ELSE
          NextLineNo := 10000;
        
        IndentPO.RESET;
        IndentPO.SETFILTER(IndentPO."Document No.","Document No.");
        IndentPO.SETRANGE(IndentPO."PO Line No.","Line No.");
        IndentPO.SETRANGE(IndentPO."Line No.",Type);
        IndentPO.SETFILTER(IndentPO.Date,"No.");
        IndentPO.SETFILTER(IndentPO.Type,"Location Code");
        IF IndentPO.FINDFIRST THEN REPEAT
           "PO Qty"+=IndentPO."P.O.Qty";
         UNTIL IndentPO.NEXT=0;
        
        
        IF PurchInvHeader."No." <> TempPurchLine."Document No." THEN
          PurchInvHeader.GET(TempPurchLine."Document Type",TempPurchLine."Document No.");
        
          PurchLine.INIT;
            REPEAT
              PurchLine."Line No."          :=  NextLineNo;
              PurchLine."Document Type"     :=  TempPurchLine."Document Type";
              PurchLine."Document No."      :=  TempPurchLine."Document No.";
              PurchLine.Type                :=  2;
              PurchLine.VALIDATE(PurchLine."No.",  "No.") ;
              PurchLine.Description         :=   Description;
              PurchLine.Description         :=   "Description 2";
              PurchLine.VALIDATE(PurchLine."Unit of Measure Code",  "Unit of Measure Code") ;
              PurchLine."Location Code"     :=  "Location Code";
              //CALCSUMS("PO Qty");
              CALCFIELDS("PO Qty");
              outstandqty := Quantity-"PO Qty";
              PurchLine.VALIDATE(PurchLine.Quantity,outstandqty) ;
              PurchLine."Indent No." :=    "Document No.";
              PurchLine.VALIDATE(PurchLine."Indent Line No.", "Line No.") ;
              IF outstandqty <>0 THEN BEGIN
                PurchLine.INSERT;
              END ELSE BEGIN
                EXIT;
              END;
        
              NextLineNo := NextLineNo + 10000;
            UNTIL PurchLine.NEXT=0;
        */

    end;
}

