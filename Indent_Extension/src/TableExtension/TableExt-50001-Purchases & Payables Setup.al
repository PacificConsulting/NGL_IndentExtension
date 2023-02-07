tableextension 50001 Purch_Pay_setup_ext extends "Purchases & Payables Setup"
{
    // version NAVW19.00.00.48466,NAVIN9.00.00.48466,//PCPL AntiCost

    fields
    {
        field(50000; "Indent No."; Code[10])
        {
            Description = 'INDENT';
            TableRelation = "No. Series";
        }

        field(50004; "Indent No.1"; Code[10])
        {
            Description = 'INDENT';
            TableRelation = "No. Series";
        }

    }

    //Unsupported feature: PropertyChange. Please convert manually.

}

