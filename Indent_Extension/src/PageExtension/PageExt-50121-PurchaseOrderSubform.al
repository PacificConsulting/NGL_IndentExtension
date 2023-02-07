pageextension 50121 Purch_order_subform_indent extends "Purchase Order Subform"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
    }
    procedure GetIndentLines()
    begin
        RunIndent;
    end;

    procedure RunIndent()
    Begin
        CLEAR(GetIndent);
        PurchHeader1.RESET;

        PurchHeader1.SETRANGE(PurchHeader1."Document Type", PurchHeader1."Document Type"::Order);
        PurchHeader1.SETRANGE(PurchHeader1."No.", "Document No.");
        //IF "Location Code"<>'' THEN
        //PurchHeader1.SETRANGE(PurchHeader1."Location Code","Location Code");
        IF PurchHeader1.FINDFIRST THEN BEGIN

            //ROBOSOFT001--START  //ROBOSOFT001--END
            PurcIndnettLine.RESET;
            PurcIndnettLine.SETRANGE(PurcIndnettLine."Location Code", PurchHeader1."Location Code");
            PurcIndnettLine.SETRANGE(PurcIndnettLine.Approved, TRUE);
            PurcIndnettLine.SETRANGE(PurcIndnettLine.Status, TRUE);
            PurcIndnettLine.SETRANGE(PurcIndnettLine."Outstanding True", FALSE);
            //ROBOSOFT001--END
            GetIndent.SETTABLEVIEW(PurcIndnettLine);

            GetIndent.LOOKUPMODE := TRUE;
        END;
        GetIndent.EDITABLE(FALSE);
        GetIndent.SetPurchHeaderIndent(PurchHeader1);
        IF GetIndent.RUNMODAL <> ACTION::Cancel THEN;

    End;

    var
        PurchHeader1: Record 38;
        GetIndent: page 50013;
        PurcIndnettLine: Record 50003;
}