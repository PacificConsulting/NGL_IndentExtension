tableextension 50000 Requisition_Line_Ext extends "Requisition Line"
{
    // version NAVW19.00.00.48316

    fields
    {
        field(50000; Indented; Boolean)
        {
        }
        field(50001; "Entry no"; Code[20])
        {
            Description = 'INDENT';
        }
        field(50002; "Indent Line No"; Integer)
        {
        }
        field(50003; Comment; Text[230])
        {
            Description = 'PCPL BRB';
        }
    }

    //Unsupported feature: PropertyChange. Please convert manually.

}

