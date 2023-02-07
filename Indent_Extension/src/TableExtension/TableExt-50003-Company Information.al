tableextension 50003 Com_Info_Ext extends "Company Information"
{
    // version NAVW19.00.00.48067,NAVIN9.00.00.48067,GITLEXIM,TFS180484

    fields
    {


        // field(50000;"Insurance Policy No";Code[50])
        // {
        //     Description = 'KAR1.0';
        // }
        // field(50001;"Drug License No.";Code[20])
        // {
        //     Description = 'KAR 1.0';
        // }
        // field(50002;"IEC CODE No.";Code[20])
        // {
        //     Description = 'Sanjay 16/02/2015';
        // }
        // field(50003;"END Use Code";Code[20])
        // {
        // }
        field(50004; "Indent Closing Period"; DateFormula)
        {
            Description = 'pcpl002430oct';
        }
    }

    //Unsupported feature: PropertyChange. Please convert manually.

}

