defmodule Engine.Controllers.HelpersTest do
  use Engine.ConnCase

  alias Engine.Controllers.Helpers

  test "calc_day_fee_inc_holidays(fee_per_day_inc_holiday, day_fee_multiplier)" do
    day_fee_inc_holidays =  Helpers.calc_day_fee_inc_holidays(2, 1)

    assert day_fee_inc_holidays == 2
  end

  test "calc_day_fee_exc_holidays(fee_per_day_exc_holiday, day_fee_multiplier)" do
    day_fee_exc_holidays =  Helpers.calc_day_fee_exc_holidays(2, 1)

    assert day_fee_exc_holidays == 2
  end

  test "calc_fee_per_day_exc_holiday(fee_per_day_inc_holiday, project_holiday_rate)" do
    fee_per_day_exc_holiday =  Helpers.calc_fee_per_day_exc_holiday(2, 1)

    assert fee_per_day_exc_holiday == 1
  end

  test "calc_holiday_pay_per_day(fee_per_day_inc_holiday, fee_per_day_exc_holiday)" do
    holiday_pay_per_day = Helpers.calc_holiday_pay_per_day(2.0, 1)

    assert holiday_pay_per_day == 1
  end

  test "calc_fee_per_week_inc_holiday(fee_per_day_inc_holiday, working_week)" do
    fee_per_week_inc_holiday = Helpers.calc_fee_per_week_inc_holiday(1.0, 1)

    assert fee_per_week_inc_holiday == 1
  end

  test "calc_fee_per_week_exc_holiday(fee_per_week_inc_holiday, project_holiday_rate)" do
    fee_per_week_exc_holiday = Helpers.calc_fee_per_week_exc_holiday(2, 1)

    assert fee_per_week_exc_holiday == 1
  end

  test "calc_holiday_pay_per_week(fee_per_week_inc_holiday, fee_per_week_exc_holiday)" do
    holiday_pay_per_week = Helpers.calc_holiday_pay_per_week(2.0, 1)

    assert holiday_pay_per_week == 1
  end

  test "determine_contract_type(department, job_title) Accounts" do
    sch_d_contract = Helpers.determine_contract_type("Accounts", "Financial Controller", [], false, false)
    paye_contract = Helpers.determine_contract_type("Accounts", "Accounts Clerk", [], false, false)

    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Action Vehicles" do
    paye_contract = Helpers.determine_contract_type("Action Vehicles", "Carriage Master", [], false, false)

    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Assistant Directors" do
    sch_d_contract = Helpers.determine_contract_type("Assistant Director", "1st Assistant Director", [], false, false)
    paye_contract = Helpers.determine_contract_type("Assistant Director", "2nd Assistant Director", [], false, false)

    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Aerial" do
    sch_d_contract = Helpers.determine_contract_type("Aerial", "Aerial Cameraman", [], false, false)

    assert sch_d_contract == "SCHEDULE-D"
  end

  test "determine_contract_type(department, job_title) Animals" do
    sch_d_contract = Helpers.determine_contract_type("Animals", "Animal Wrangler", [], false, false)
    paye_contract = Helpers.determine_contract_type("Animals", "Assistant Horse Master", [], false, false)

    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Armoury" do
    sch_d_contract = Helpers.determine_contract_type("Armoury", "Archery Instructor", [], false, false)
    paye_contract = Helpers.determine_contract_type("Armoury", "Armoury Concept Artist", [], false, false)
    conditional_contract = Helpers.determine_contract_type("Armoury", "Senior Model Maker", [], false, false)

    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
    assert conditional_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Art" do
    sch_d_contract = Helpers.determine_contract_type("Art", "Art Director", [], false, false)
    paye_contract = Helpers.determine_contract_type("Art", "Art Trainee", [], false, false)
    conditional_contract = Helpers.determine_contract_type("Art", "Scenic Painter", [], false, false)


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
    assert conditional_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Camera" do
    sch_d_contract = Helpers.determine_contract_type("Camera", "Director Of Photography", [], false, false)
    paye_contract = Helpers.determine_contract_type("Camera", "1st Assistant Camera", [], false, false)
    conditional_contract = Helpers.determine_contract_type("Camera", "Camera Operator", [], false, false)


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
    assert conditional_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Cast" do
    sch_d_contract = Helpers.determine_contract_type("Cast", "Actor", [], false, false)
    paye_contract = Helpers.determine_contract_type("Cast", "Actor Double", [], false, false)
    conditional_contract = Helpers.determine_contract_type("Cast", "Unit Driver", [], false, false)


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
    assert conditional_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Construction" do
    sch_d_contract = Helpers.determine_contract_type("Construction", "Buyer", [], false, false)
    paye_contract = Helpers.determine_contract_type("Construction", "Carpenter", [], false, false)
    conditional_contract = Helpers.determine_contract_type("Construction", "Scenic Painter", [], false, false)


    assert sch_d_contract == "CONSTRUCTION SCHEDULE-D"
    assert paye_contract == "CONSTRUCTION PAYE"
    assert conditional_contract == "CONSTRUCTION PAYE"
  end

  test "determine_contract_type(department, job_title) Continuity" do
    sch_d_contract = Helpers.determine_contract_type("Continuity", "Script Supervisor", [], false, false)
    paye_contract = Helpers.determine_contract_type("Continuity", "Assistant Script Supervisor", [], false, false)

    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Costume" do
    sch_d_contract = Helpers.determine_contract_type("Costume", "Buyer", [], false, false)
    paye_contract = Helpers.determine_contract_type("Costume", "Assistant Buyer", [], false, false)
    conditional_contract = Helpers.determine_contract_type("Costume", "Seamstress", [], false, false)


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
    assert conditional_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) DIT" do
    conditional_contract = Helpers.determine_contract_type("DIT", "Data Wrangler", [], false, false)
    paye_contract = Helpers.determine_contract_type("DIT", "Array DIT", [], false, false)

    assert conditional_contract == "PAYE"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Drapes" do
    conditional_contract = Helpers.determine_contract_type("Drapes", "Drapesman", [], false, false)
    paye_contract = Helpers.determine_contract_type("Drapes", "Drapes Master", [], false, false)

    assert conditional_contract == "PAYE"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Editorial" do
    sch_d_contract = Helpers.determine_contract_type("Editorial", "Assembly Editor", [], false, false)
    paye_contract = Helpers.determine_contract_type("Editorial", "Assistant Editor", [], false, false)


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Electrical" do
    sch_d_contract = Helpers.determine_contract_type("Electrical", "VFX Editor", [], false, false)
    paye_contract = Helpers.determine_contract_type("Electrical", "Desk Operator", [], false, false)
    conditional_contract = Helpers.determine_contract_type("Electrical", "Balloon Technician", [], false, false)


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
    assert conditional_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Greens" do
    paye_contract = Helpers.determine_contract_type("Greens", "Greens Person", [], false, false)

    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Grip" do
    sch_d_contract = Helpers.determine_contract_type("Grip", "Crane Grip", [], false, false)
    paye_contract = Helpers.determine_contract_type("Grip", "Grip Rigger", [], false, false)
    conditional_contract = Helpers.determine_contract_type("Grip", "Best Boy Grip", [], false, false)


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
    assert conditional_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Hair And Makeup" do
    sch_d_contract = Helpers.determine_contract_type("Hair And Makeup", "Hair Designer", [], false, false)
    paye_contract = Helpers.determine_contract_type("Hair And Makeup", "Hairdresser", [], false, false)


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) IT" do
    paye_contract = Helpers.determine_contract_type("IT", "1st Line IT Support", [], false, false)

    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Locations" do
    sch_d_contract = Helpers.determine_contract_type("Locations", "Location Manager", [], false, false)
    paye_contract = Helpers.determine_contract_type("Locations", "Locations Marshall", [], false, false)


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Medical" do
    sch_d_contract = Helpers.determine_contract_type("Medical", "Medic", [], false, false)

    assert sch_d_contract == "SCHEDULE-D"
  end

  test "determine_contract_type(department, job_title) Military" do
    sch_d_contract = Helpers.determine_contract_type("Military", "Military Advisor", [], false, false)

    assert sch_d_contract == "SCHEDULE-D"
  end

  test "determine_contract_type(department, job_title) Photography" do
    conditional_contract = Helpers.determine_contract_type("Photography", "Photographer", [], false, false)

    assert conditional_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Post Production" do
    sch_d_contract = Helpers.determine_contract_type("Post Production", "Post Production Supervisor", [], false, false)
    paye_contract = Helpers.determine_contract_type("Post Production", "Coordinator", [], false, false)


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Production" do
    sch_d_contract = Helpers.determine_contract_type("Production", "Co-Producer", [], false, false)
    paye_contract = Helpers.determine_contract_type("Production", "Cast Assistant", [], false, false)


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Props" do
    sch_d_contract = Helpers.determine_contract_type("Props", "HOD Prop Modeller", [], false, false)
    paye_contract = Helpers.determine_contract_type("Props", "Chargehand Dresser", [], false, false)
    conditional_contract = Helpers.determine_contract_type("Props", "Chargehand Dressing Prop", [], false, false)


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
    assert conditional_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Publicity" do
    sch_d_contract = Helpers.determine_contract_type("Publicity", "Unit Publicist", [], false, false)

    assert sch_d_contract == "SCHEDULE-D"
  end

  test "determine_contract_type(department, job_title) Rigging" do
    sch_d_contract = Helpers.determine_contract_type("Rigging", "HOD Rigger", [], false, false)
    paye_contract = Helpers.determine_contract_type("Rigging", "Rigger", [], false, false)


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Security" do
    paye_contract = Helpers.determine_contract_type("Security", "Security", [], false, false)

    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Set Dec" do
    sch_d_contract = Helpers.determine_contract_type("Set Dec", "Art Director", [], false, false)
    paye_contract = Helpers.determine_contract_type("Set Dec", "Coordinator", [], false, false)
    conditional_contract = Helpers.determine_contract_type("Set Dec", "Scenic Textile Artist", [], false, false)


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
    assert conditional_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) SFX" do
    sch_d_contract = Helpers.determine_contract_type("SFX", "Floor Director", [], false, false)
    paye_contract = Helpers.determine_contract_type("SFX", "Floor Technician", [], false, false)


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Sound" do
    sch_d_contract = Helpers.determine_contract_type("Sound", "Production Sound Mixer", [], false, false)
    paye_contract = Helpers.determine_contract_type("Sound", "1st Assistant Sound", [], false, false)


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Standby" do
    paye_contract = Helpers.determine_contract_type("Standby", "Rigger", [], false, false)

    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Studio Unit" do
    paye_contract = Helpers.determine_contract_type("Studio Unit", "Studio Unit Manager", [], false, false)

    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Stunts" do
    sch_d_contract = Helpers.determine_contract_type("Stunts", "Stunt Coordinator", [], false, false)
    paye_contract = Helpers.determine_contract_type("Stunts", "Rigger", [], false, false)
    conditional_contract = Helpers.determine_contract_type("Stunts", "Wire Rigger", [], false, false)


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
    assert conditional_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Supporting Artist" do
    sch_d_contract = Helpers.determine_contract_type("Supporting Artist", "Pay Direct Extra", [], false, false)

    assert sch_d_contract == "SCHEDULE-D"
  end

  test "determine_contract_type(department, job_title) Transport" do
    sch_d_contract = Helpers.determine_contract_type("Transport", "Transport Captain", ["TRANSPORT DIRECT HIRE"], false, false)
    paye_contract = Helpers.determine_contract_type("Transport", "Transport Coordinator", ["TRANSPORT DIRECT HIRE"], false, false)
    conditional_contract = Helpers.determine_contract_type("Transport", "Unit Driver", ["TRANSPORT DIRECT HIRE"], false, false)
    direct_hire = Helpers.determine_contract_type("Transport", "Rushes Runner", ["TRANSPORT DIRECT HIRE"], false, false)


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
    assert conditional_contract == "TRANSPORT PAYE"
    assert direct_hire == "TRANSPORT DIRECT HIRE"
  end

  test "determine_contract_type(department, job_title) Underwater" do
    sch_d_contract = Helpers.determine_contract_type("Underwater", "Cameraman", [], false, false)

    assert sch_d_contract == "SCHEDULE-D"
  end

  test "determine_contract_type(department, job_title) VFX" do
    sch_d_contract = Helpers.determine_contract_type("VFX", "VFX Producer", [], false, false)
    paye_contract = Helpers.determine_contract_type("VFX", "Data Wrangler", [], false, false)


    assert sch_d_contract == "SCHEDULE-D"
    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Video" do
    paye_contract = Helpers.determine_contract_type("Video", "Video Assistant", [], false, false)

    assert paye_contract == "PAYE"
  end

  test "determine_contract_type(department, job_title) Voice" do
    sch_d_contract = Helpers.determine_contract_type("Voice", "Voice Coach", [], false, false)

    assert sch_d_contract == "SCHEDULE-D"
  end

  test "determine_contract_type daily contracts" do
    daily_construction_direct_hire_paye = Helpers.determine_contract_type("Construction", "Crew Chef", ["DAILY CONSTRUCTION DIRECT HIRE"], true, false)
    daily_construction_direct_hire_overwrite_paye = Helpers.determine_contract_type("Construction", "Crew Chef", ["DAILY CONSTRUCTION DIRECT HIRE", "CONSTRUCTION DIRECT HIRE"], true, false)
    daily_construction_direct_hire_sch_d = Helpers.determine_contract_type("Construction", "Cast Chef", ["DAILY CONSTRUCTION DIRECT HIRE"], true, false)
    daily_construction_direct_hire_overwrite_sch_d = Helpers.determine_contract_type("Construction", "Cast Chef", ["DAILY CONSTRUCTION DIRECT HIRE", "CONSTRUCTION DIRECT HIRE"], true, false)
    daily_transport_direct_hire_paye = Helpers.determine_contract_type("Transport", "Transport Operator", ["DAILY TRANSPORT DIRECT HIRE"], true, false)
    daily_transport_paye = Helpers.determine_contract_type("Transport", "Transport Operator", ["DAILY TRANSPORT PAYE"], true, false)
    daily_transport_direct_hire_overwrite_paye = Helpers.determine_contract_type("Transport", "Transport Coordinator", ["DAILY CONSTRUCTION DIRECT HIRE", "CONSTRUCTION DIRECT HIRE", "DIRECT HIRE"], true, false)
    daily_transport_direct_hire_sch_d = Helpers.determine_contract_type("Transport", "Transport Captain", ["DAILY TRANSPORT DIRECT HIRE", "DAILY DIRECT HIRE"], true, false)
    daily_transport_direct_hire_overwrite_sch_d = Helpers.determine_contract_type("Transport", "Transport Manager", ["DAILY DIRECT HIRE", "DIRECT HIRE"], true, false)

    assert daily_construction_direct_hire_paye == "DAILY CONSTRUCTION DIRECT HIRE"
    assert daily_construction_direct_hire_overwrite_paye == "DAILY CONSTRUCTION DIRECT HIRE"
    assert daily_construction_direct_hire_sch_d == "DAILY CONSTRUCTION DIRECT HIRE"
    assert daily_construction_direct_hire_overwrite_sch_d == "DAILY CONSTRUCTION DIRECT HIRE"
    assert daily_transport_direct_hire_paye == "DAILY TRANSPORT DIRECT HIRE"
    assert daily_transport_direct_hire_overwrite_paye == "DIRECT HIRE"
    assert daily_transport_direct_hire_sch_d == "DAILY DIRECT HIRE"
    assert daily_transport_paye == "DAILY TRANSPORT PAYE"
    assert daily_transport_direct_hire_overwrite_sch_d == "DAILY DIRECT HIRE"
  end

  test "determine_contract_type PAYE equipment -> SCHEDULE-D" do
    paye_equipment_schedule_d_contract = Helpers.determine_contract_type("Video", "Video Assistant", [], false, true)
    daily_paye_equipment_schedule_d_contract = Helpers.determine_contract_type("Video", "Video Assistant", ["DAILY PAYE", "DAILY SCHEDULE-D"], true, true)

    assert paye_equipment_schedule_d_contract == "PAYE"
    assert daily_paye_equipment_schedule_d_contract == "DAILY PAYE"
  end
end
