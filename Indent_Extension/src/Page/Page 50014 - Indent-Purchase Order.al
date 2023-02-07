page 50014 "Indent-Purchase Order"
{
    // version RSPL/INDENT/V3/001

    PageType = List;
    SourceTable = 50003;
    ApplicationArea = all;
    UsageCategory = Lists;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document No."; "Document No.")
                {
                    ApplicationArea = all;
                }
                field(Date; Date)
                {
                    ApplicationArea = all;
                }
                field(Type; Type)
                {
                    ApplicationArea = all;
                }
                field("No."; "No.")
                {
                    ApplicationArea = all;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = all;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = all;
                }
                field("PO Qty"; "PO Qty")
                {
                    ApplicationArea = all;
                }
                field(Approved; Approved)
                {
                    ApplicationArea = all;
                }
                field("Approved Date"; "Approved Date")
                {
                    ApplicationArea = all;
                }
                field(Description; Description)
                {
                    ApplicationArea = all;
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = all;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = all;
                }
                field(Category; Category)
                {
                    ApplicationArea = all;
                }
                field("Requisition Line No."; "Requisition Line No.")
                {
                    ApplicationArea = all;
                }
                field("Requisition Templet Name"; "Requisition Templet Name")
                {
                    ApplicationArea = all;
                }
                field("Requisition Batch Name"; "Requisition Batch Name")
                {
                    ApplicationArea = all;
                }
                field("Outstanding True"; "Outstanding True")
                {
                    ApplicationArea = all;
                }
                field(Close; Close)
                {
                    ApplicationArea = all;
                }
                field("Description 3"; "Description 3")
                {
                    ApplicationArea = all;
                }
                field("Material Requisitioned"; "Material Requisitioned")
                {
                    ApplicationArea = all;
                }
                field(Remark; Remark)
                {
                    ApplicationArea = all;
                }
                field("USER ID"; "USER ID")
                {
                    ApplicationArea = all;
                }
                field("FA Component Category"; "FA Component Category")
                {
                    ApplicationArea = all;
                }
                field("Requirement Date"; "Requirement Date")
                {
                    ApplicationArea = all;
                }
                field("Product Group Code"; "Product Group Code")
                {
                    ApplicationArea = all;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage();
    var
        RecUser: Record 91;
        TmpLocCode: Code[100];
    begin
        //PCPL0041-13022020-Start
        //FILTERGROUP(2);
        //SETFILTER("PO Qty",'%1',0);
        //FILTERGROUP(0);
        //PCPL0041-13022020-End

        //PCPL0017
        //RecUser.RESET;
        //RecUser.SETRANGE(RecUser."User ID",USERID);

        //IF RecUser.FINDFIRST THEN
        //BEGIN
        //TmpLocCode := RecUser."Location Code";
        //END;
        //IF TmpLocCode <> '' THEN
        //BEGIN
        //FILTERGROUP(2);
        //SETFILTER("Location Code",TmpLocCode);
        //FILTERGROUP(0);
        //END;
        //PCPL0017
    end;
}

