table 50001 "Schedule Detail"
{
    // version RSPL/INDENT/V3/001


    fields
    {
        field(1; "Entry Type"; Option)
        {
            OptionMembers = Indent;
        }
        field(2; "Document No"; Code[20])
        {
        }
        field(7; "Line No"; Integer)
        {
        }
        field(8; Item; Code[20])
        {
        }
        field(9; "Due Date"; Date)
        {
        }
        field(10; Quantity; Integer)
        {

            trigger OnValidate();
            begin
                REPEAT
                    "Total Quantity" += Quantity;
                UNTIL NEXT = 0;
                //MESSAGE('%1,%2',"Total Quantity",Quantity);
                IndentLineRec.RESET;
                IndentLineRec.SETRANGE(IndentLineRec."Entry Type", ScheduleRec."Entry Type");
                IndentLineRec.SETRANGE(IndentLineRec."Document No.", "Document No");
                IndentLineRec.SETRANGE(IndentLineRec.Type, type);
                IndentLineRec.SETRANGE(IndentLineRec."No.", Item);
                IndentLineRec.SETRANGE(IndentLineRec."Line No.", "Indent Line No");
                IF IndentLineRec.FINDFIRST THEN BEGIN
                    IF "Total Quantity" > IndentLineRec.Quantity THEN
                        ERROR('Schedule Detail Quantity %1 should not be Grater then Indent Quantity %2', Quantity, IndentLineRec.Quantity);
                END;
            end;
        }
        field(11; type; Option)
        {
            OptionMembers = "< ","G/L Account",Item,,"Fixed Asset","Charge (Item)>";
        }
        field(12; "Indent Line No"; Integer)
        {
        }
        field(13; "Total Quantity"; Integer)
        {
        }
    }

    keys
    {
        key(Key1; "Entry Type", "Document No", Item, type, "Indent Line No", "Line No")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Qty: Decimal;
        IndentLineRec: Record 50003;
        ScheduleRec: Record 50001;
}

