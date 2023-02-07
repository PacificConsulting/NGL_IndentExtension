tableextension 50009 Job_Planing_Line extends "Job Planning Line"
{
    fields
    {
        field(50000; "Qty. to Indent"; Decimal)
        {
            Description = 'PCPL-JOB0001';

            trigger OnValidate();
            begin
                IF ("Qty. to Indent" + "Qty. Indented") > Quantity THEN
                    ERROR('Can not exceed qty');
            end;
        }
        field(50001; "Qty. Indented"; Decimal)
        {
            Description = 'PCPL-JOB0001';
        }
    }

    var
        myInt: Integer;
}