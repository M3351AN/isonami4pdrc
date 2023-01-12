
    client.log("")
    client.log("                       _oo0oo_")
    client.log("                      o8888888o")
    client.log("                      88\" . \"88")
    client.log("                      (| -_- |)")
    client.log("                      0\\  =  /0")
    client.log("                    ___/`---\'\\___")
    client.log("                  .\' \\\\|     |# \'.")
    client.log("                 / \\|||  :  |||# \\")
    client.log("                / _||||| -:- |||||- \\")
    client.log("               |   | \\\\  -  #/ |   |")
    client.log("               | \\_|  \'\'\\---/\'\'  |_/ |")
    client.log("               \\  .-\\__  \'-\'  ___/-. /")
    client.log("             ___\'. .\'  /--.--\\  `. .\'___")
    client.log("          .\"\" *<  `.___\\_<|>_/___.\' >* \"\".")
    client.log("         | | :  `- \\`.;`\\ _ /`;.`/ - ` : | |")
    client.log("         \\  \\ `_.   \\_ __\\ /__ _/   .-` /  /")
    client.log("     =====`-.____`.___ \\_____/___.-`___.-\'=====")
    client.log("")
    client.log("              佛祖保佑         永无BUG")
    client.log("Author: m1tzw#5953 A.K.A. Teikumo / Crespy / YKK / Tak.Yuuki / Zuiun1337")
    client.log("")
--da, ia ist m1tZw desu!!
local onShotFl = ui.add_checkbox("onShotFl0")
local fakeFlip = ui.add_checkbox("fakeFlip")
local thirdPersonDist = ui.add_slider("thirdPersonDist", 0, 200)
local breakLegAnim = ui.add_checkbox("breakLegAnim")
local airShot = ui.add_checkbox("airShot")
local airHitChance = ui.add_slider("airHitChance",0,100)
local slowWalkFl = ui.add_checkbox("slowWalkFl")
local slowWalkFlAmount = ui.add_slider("slowWalkFlAmount",1,14)
local fpsBoost = ui.add_button("fpsBoost")

local lP = engine.get_local_player()
local lPEntity = entity_list.get_client_entity(lP)
local camIdealDist = cvar.find_var("cam_idealdist")
local m_flPoseParameter = lPEntity:get_prop("DT_BasePlayer", "m_flPoseParameter")
local xVelocity =lPEntity:get_prop("DT_BasePlayer", "m_vecVelocity[0]")
local yVelocity =lPEntity:get_prop("DT_BasePlayer", "m_vecVelocity[1]")
local m_fFlags = lPEntity:get_prop("DT_BasePlayer", "m_fFlags")


local flSetting = ui.get("Rage", "Anti-aim", "Fake-lag", "Fake lag")
local flAmountSetting = ui.get("Rage", "Anti-aim", "Fake-lag", "Fake lag amount")
local desyncSetting = ui.get("Rage", "Anti-aim", "General", "Body yaw limit")
local desyncSideSetting = ui.get("Rage", "Anti-aim", "General", "Fake yaw direction")
local slideWalkSetting = ui.get("Misc", "General", "Movement", "Leg movement")
local hitChanceSetting = ui.get_rage("Accuracy","Hitchance")
local autoStrafeSetting = ui.get("Misc", "General", "Movement", "Auto strafe")
local slowMotionSetting = ui.get("Misc", "General", "Movement", "Slow motion key")

local resetShot = false
local resetAir = false
local airTime = 0
local fakeTime = 0
local resetPaint = false
local resetTick = false
local resetFl = false
local shotTime = 0
local originDesync = 0
local originFl = 0
local originHitChance = 0

fpsBoost:add_callback(function()
    cvar.find_var("r_3dsky"):set_value_int(0)
    cvar.find_var("r_shadows"):set_value_int(0)
    cvar.find_var("cl_csm_static_prop_shadows"):set_value_int(0)
    cvar.find_var("cl_csm_shadows"):set_value_int(0)
    cvar.find_var("cl_csm_world_shadows"):set_value_int(0)
    cvar.find_var("cl_foot_contact_shadows"):set_value_int(0)
    cvar.find_var("cl_csm_viewmodel_shadows"):set_value_int(0)
    cvar.find_var("cl_csm_rope_shadows"):set_value_int(0)
    cvar.find_var("cl_csm_sprite_shadows"):set_value_int(0)
    cvar.find_var("cl_disablefreezecam"):set_value_int(1)
    cvar.find_var("cl_freezecampanel_position_dynamic"):set_value_int(0)
    cvar.find_var("cl_freezecameffects_showholiday"):set_value_int(0)
    cvar.find_var("cl_showhelp"):set_value_int(0)
    cvar.find_var("cl_autohelp"):set_value_int(0)
    cvar.find_var("cl_disablehtmlmotd"):set_value_int(1)
    cvar.find_var("mat_postprocess_enable"):set_value_int(0)
    cvar.find_var("fog_enable_water_fog"):set_value_int(0)
    cvar.find_var("gameinstructor_enable"):set_value_int(0)
    cvar.find_var("cl_csm_world_shadows_in_viewmodelcascade"):set_value_int(0)
    cvar.find_var("cl_disable_ragdolls"):set_value_int(1)
    client.log("fps boosted!")
end)

callbacks.register("paint", function()
    resetPaint = not resetPaint
    if breakLegAnim:get() then
        if client.choked_commands() == 0 then
            m_flPoseParameter:set_int(1)
            slideWalkSetting:set(2)
        else
            if resetPaint then 
            m_flPoseParameter:set_float_index(6, 0)
            slideWalkSetting:set(2) 
            else 
            m_flPoseParameter:set_float_index(6, 1)
            slideWalkSetting:set(1)
            end
        end
    end
    camIdealDist:set_value_int(thirdPersonDist:get())
end)

callbacks.register("predicted_move", function()
    if not client.is_alive() then
        return
    end
    resetTick = not resetTick
    if fakeFlip:get()then
        if fakeTime < global_vars.curtime then
            if desyncSideSetting:get() == 1 then
                desyncSideSetting:set(2)
            else
                desyncSideSetting:set(1)
            end
            fakeTime = global_vars.curtime + 0.23
        end
    end
    if airShot:get()then
        local sumVelocity = math.sqrt(xVelocity:get_float()*xVelocity:get_float()+yVelocity:get_float()*yVelocity:get_float())
        if sumVelocity > 5 then
            autoStrafeSetting:set(true) 
        else
            autoStrafeSetting:set(false)--set autostrafe off
        end
        if not resetAir then
            if m_fFlags:get_int() == 256 then
                hitChanceSetting:set(airHitChance:get())
                airTime = global_vars.curtime + 0.2
                resetAir = true
            else
                originHitChance = hitChanceSetting:get()
            end
        end
        if airTime < global_vars.curtime and resetAir then
            hitChanceSetting:set(originHitChance)
            resetAir = false
        end
    end
    if resetShot and shotTime < global_vars.tickcount then 
        if onShotFl:get() then
            desyncSetting:set(originDesync)--reset desync
            flSetting:set(true)
        end
        resetShot = false
        return
    end
    if resetShot and shotTime > global_vars.tickcount and onShotFl:get() then--anti other luas.15ticks such long long a time right?
        desyncSetting:set(0)--keep desync 0
        flSetting:set(false)
        return
    end
end)
callbacks.register("post_move", function(cmd) 
    if slowWalkFl:get()then
        if slowMotionSetting:get_key() == true and not resetFl then
            originFl = flAmountSetting:get()
            flAmountSetting:set(slowWalkFlAmount:get()) 
            resetFl = true
        elseif resetFl then
            flAmountSetting:set(originFl)
            resetFl = false
        else
            return
        end
    end
end)


callbacks.register("weapon_fire",function(event)
    local fireman = event:get_int("userid");
    local firemanIndex = engine.get_player_for_user_id(fireman);
    if firemanIndex == lP and not resetShot  then
        if onShotFl:get() then
            originDesync = desyncSetting:get() --fetch origin fl
            desyncSetting:set(0)--set desync 0
            flSetting:set(false)
        end
        shotTime = global_vars.tickcount + 15
        resetShot = true
        return
    end
    if firemanindex == lP and resetShot  then
        if onShotFl:get() then
            desyncSetting:set(0)--set desync 0
            flSetting:set(false)
        end
        shotTime = global_vars.tickcount + 15
        return
    end
end)