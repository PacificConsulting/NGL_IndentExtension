tableextension 50002 Purchase_Line_indent extends "Purchase Line"
{
    fields
    {
        field(50021; "Material Requisition"; Text[50])
        {
            Description = 'INDENT';

            trigger OnValidate();
            begin
                TestStatusOpen;
            end;
        }
        field(50022; "FA Component Category"; Code[20])
        {
            Description = 'INDENT';
            // TableRelation = test3.test;

            trigger OnValidate();
            begin
                TestStatusOpen;
            end;
        }
        field(50023; "Indent No."; Code[20])
        {
            Description = 'PCPL-Indent';

            trigger OnValidate();
            begin
                TestStatusOpen;
            end;
        }
        field(50024; "Indent Line No."; Integer)
        {
            Description = 'PCPL-Indent';

            trigger OnValidate();
            begin
                TestStatusOpen;
            end;
        }
    }
    trigger OnDelete()
    begin
        //VK001 - to delete indent purchase order table
        IF "Quantity Received" = 0 THEN BEGIN
            IPO.SETRANGE(IPO."P.O.No.", "Document No.");
            IPO.SETRANGE(IPO."PO Line No.", "Line No.");
            IF IPO.FINDSET THEN
                IPO.DELETEALL;
        END;
        //VK001


        //VK001--To Update Purchase Indent
        recIndent.RESET;
        recIndent.SETRANGE(recIndent."Document No.", "Indent No.");
        recIndent.SETRANGE(recIndent."Line No.", "Indent Line No.");
        IF recIndent.FINDFIRST THEN BEGIN
            recIndent."Outstanding True" := FALSE;
            recIndent.MODIFY;
        END;

    end;

    var
        myInt: Integer;
        IPO: record 50005;
        recIndent: Record 50003;
}