page 50012 "Indent Header-List"
{
    // version RSPL/INDENT/V3/001

    CardPageID = "Purchase Indent";
    PageType = List;
    SourceTable = 50002;
    SourceTableView = SORTING("No.", "Entry Type")
                      WHERE(Status = FILTER(<> Closed));
    ApplicationArea = all;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry Type"; "Entry Type")
                {
                    ApplicationArea = all;
                }
                field("No."; "No.")
                {
                    ApplicationArea = all;
                }
                field(Date; Date)
                {
                    ApplicationArea = all;
                }
                field("Created By"; "Created By")
                {
                    ApplicationArea = all;
                }
                field("Creation Date"; "Creation Date")
                {
                    ApplicationArea = all;
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = all;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = all;
                }
                field("No. Series"; "No. Series")
                {
                    Editable = true;
                    ApplicationArea = all;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = all;
                }
                field("Total Qty"; "Total Qty")
                {
                    ApplicationArea = all;
                }
                field(Category; Category)
                {
                    ApplicationArea = all;
                    OptionCaption = '" ,Engineering,Raw Materials,Lab Equipment,Lab Chemicals,Packing Material,Safety,Production,Information Technology,Bldg. No1,Bldg No.2,Bldg No.3,QA,Warehouse,SRP,ETP & MEE,Utility,Formulation>"';
                }
                field(Purpose; Purpose)
                {
                    ApplicationArea = all;
                    OptionCaption = '" ,Project,Maintenance,Production,Quality Control,Research and Devolopment,Electrical,Instrument,Civil>"';
                }
                field(Status; Status)
                {
                    ApplicationArea = all;
                    Editable = true;
                }
                field("Release User ID"; "Release User ID")
                {
                    ApplicationArea = all;
                }
                field("Material category"; "Material category")
                {
                    ApplicationArea = all;
                }
                field("Closed By"; "Closed By")
                {
                    ApplicationArea = all;
                }
                field("Closed Date"; "Closed Date")
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
        //PCPL-25
        RecUser.RESET;
        RecUser.SETRANGE(RecUser."User ID", USERID);
        IF RecUser.FINDFIRST THEN BEGIN
            TmpLocCode := RecUser."Location Code";
        END;

        IF TmpLocCode <> '' THEN BEGIN
            FILTERGROUP(2);
            SETFILTER("Location Code", TmpLocCode);
            FILTERGROUP(0);
        END;
        //PCPL-25
    end;
}

