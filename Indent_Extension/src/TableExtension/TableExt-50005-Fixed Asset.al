tableextension 50005 Fixed_asset_ext extends "Fixed Asset"
{
    // version NAVW19.00.00.48466,NAVIN9.00.00.48466,//PCPL-FA

    fields
    {

        //Unsupported feature: Change Data type on ""Serial No."(Field 17)". Please convert manually.


        //Unsupported feature: Change TableRelation on ""GST Group Code"(Field 16602)". Please convert manually.

        field(50007; "Blocked Type"; Option)
        {
            Description = 'indent';
            OptionCaption = '" ,Indent,Purchase"';
            OptionMembers = " ",Indent,Purchase;
        }
    }

}

