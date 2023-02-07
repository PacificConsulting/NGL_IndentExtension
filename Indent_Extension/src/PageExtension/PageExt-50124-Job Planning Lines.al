pageextension 50124 Job_Planning_lines extends "Job Planning Lines"
{
    // version NAVW19.00.00.47444,PCPL-JOB0001

    layout
    {

        addafter(Description)
        {
            field("Description 2"; "Description 2")
            {
                ApplicationArea = all;
            }

        }
        addafter(Overdue)
        {
            field("Qty. to Indent"; "Qty. to Indent")
            {
                ApplicationArea = all;
            }
            field("Qty. Indented"; "Qty. Indented")
            {
                ApplicationArea = all;
            }
        }
    }
    actions
    {
        addafter(DemandOverview)
        {
            action("Create Indent")
            {
                Image = Indent;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction();
                var
                    IndentHdr: Record 50002;
                    IndentLine: Record 50003;
                    JobPlanningLine: Record 1003;
                    vLineNo: Integer;
                    recItem: Record 27;
                    JobCard: Record 167;
                begin
                    //>>PCPL-JOB0001

                    JobPlanningLine.RESET;
                    JobPlanningLine.SETRANGE(JobPlanningLine."Job No.", "Job No.");
                    JobPlanningLine.SETRANGE(JobPlanningLine."Job Task No.", "Job Task No.");
                    JobPlanningLine.SETRANGE(JobPlanningLine."Location Code", "Location Code");
                    JobPlanningLine.SETFILTER("Qty. to Indent", '>%1', 0);
                    IF JobPlanningLine.FINDSET THEN BEGIN
                        IndentHdr.INIT;
                        IndentHdr."Entry Type" := IndentHdr."Entry Type"::Indent;
                        IndentHdr.INSERT(TRUE);
                        IndentHdr.Date := JobPlanningLine."Document Date";
                        IndentHdr."Created By" := USERID;
                        IndentHdr."Creation Date" := WORKDATE;
                        //IndentHdr.VALIDATE("Shortcut Dimension 1 Code",
                        IndentHdr.VALIDATE("Location Code", "Location Code");
                        recItem.GET(JobPlanningLine."No.");
                        IndentHdr.Category := IndentHdr.Category::" ";
                        IndentHdr."Material category" := recItem."Item Category Code";
                        JobCard.GET(JobPlanningLine."Job No.");
                        IndentHdr.Purpose := JobCard.Purpose;
                        IndentHdr."Job No." := JobPlanningLine."Job No.";
                        IndentHdr."Job Task No." := JobPlanningLine."Job Task No.";
                        IndentHdr.MODIFY;
                        REPEAT
                            vLineNo += 10000;
                            IndentLine.INIT;
                            IndentLine."Entry Type" := IndentHdr."Entry Type";
                            IndentLine."Document No." := IndentHdr."No.";
                            IndentLine."Line No." := vLineNo;
                            IndentLine.INSERT(TRUE);
                            IndentLine.Type := IndentLine.Type::Item;
                            IndentLine.VALIDATE("No.", JobPlanningLine."No.");
                            IndentLine.VALIDATE(Quantity, JobPlanningLine."Qty. to Indent");
                            IndentLine."Job No." := JobPlanningLine."Job No.";
                            IndentLine."Job Task No." := JobPlanningLine."Job Task No.";
                            IndentLine."Job Planning Line No." := JobPlanningLine."Line No.";
                            IndentLine.MODIFY;
                            JobPlanningLine."Qty. Indented" += JobPlanningLine."Qty. to Indent";
                            JobPlanningLine."Qty. to Indent" := 0;
                            JobPlanningLine.MODIFY;
                        UNTIL JobPlanningLine.NEXT = 0;
                        MESSAGE('Indent %1 created successfully', IndentHdr."No.");
                    END;
                    //<<PCPL-JOB0001

                end;
            }
        }
    }

    var
        BTHHJ: report 1401;

    

}

