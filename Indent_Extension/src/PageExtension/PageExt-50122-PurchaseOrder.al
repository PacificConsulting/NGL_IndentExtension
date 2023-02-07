pageextension 50122 Purchase_order_Indent extends "Purchase Order"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addafter("Remove From Job Queue")
        {
            action("Get Indent Line")
            {
                Image = Process;
                Promoted = true;
                PromotedIsBig = true;
                ApplicationArea = all;

                trigger OnAction();
                begin
                    PHEader.RESET;
                    PHEader.SETRANGE(PHEader."Document Type", PHEader."Document Type"::Order);
                    PHEader.SETRANGE("No.", "No.");
                    IF PHEader.FINDFIRST THEN BEGIN
                        CurrPage.PurchLines.PAGE.GetIndentLines;
                    END;
                end;
            }

        }
    }

    var
        PHEader: Record 38;
}