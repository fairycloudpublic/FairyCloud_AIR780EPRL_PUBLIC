-- sys库是标配
sys = require("sys")

-- 启动时对rtc进行判断和初始化
local reason, slp_state = pm.lastReson()
log.info("wakeup state", pm.lastReson())

-- 正常开机判断  reason 0正常开机
sys.taskInit(function()

	if reason > 0 then
	    pm.request(pm.IDLE)
	    pm.power(pm.USB, true)
        mobile.flymode(0, false)--关闭飞行模式

	    log.info("-------------------已经从深度休眠唤醒-------------------") 
	else		   
	    log.info("-------------------普通复位，开始运行-------------------")
	end

end)




-- 自动休眠处理
function autoRestDeep()

	log.info("----------autoRestDeep，即将进入深度休眠-----------")
	sys.wait(500) --等待MQTT断开传输完毕

    -- 关闭GPS电源开关
    gpio.set(21,0)

    gpio.setup(23,nil)
	gpio.close(35)
    gpio.close(33) --如果功耗偏高，开始尝试关闭WAKEUPPAD1
	sys.wait(200)

	--打开飞行模式
	mobile.flymode(0, true)
	pm.power(pm.USB, false)
	sys.wait(200)
	
	pm.dtimerStart(3,_G.deeprest_time)
	pm.power(pm.WORK_MODE,3)
    
end


function REST_SEND_RESTDEEP()
    sys.taskInit(function()
        autoRestDeep()
    end)

end


-- 订阅 
sys.subscribe("REST_SEND_RESTDEEP",REST_SEND_RESTDEEP)




-- if reason > 0 then
--     pm.request(pm.IDLE)
--     --pm.power(pm.WORK_MODE,3)
--     mobile.flymode(0, true)--打开飞行模式
--     pm.power(pm.USB, true)
--     log.info("-------------------已经从深度休眠唤醒-------------------")    
--     sys.taskInit(function()
--         log.info("-------------------等联网完成--------------------------")
--         log.info("----------------上传GPS数据后再次进入深度休眠-------------------")
--         sys.wait(2000)


--         --while true do
--                 sys.subscribe(_G.GPS_Ggt_Topic,function()--------->subscribe里面不能有sys.wait
--                     sys.unsubscribe(_G.GPS_Ggt_Topic,function()
--                         log.info("---------------------->>取消订阅<<----------------------")
--                     end)
--                     mobile.flymode(0, false)--关闭飞行模式
--                     log.info("-------------------->>关闭飞行模式<<----------------------") 
--                     --sys.waitUntil(_G.Updata_OK,10*1000)--------->subscribe里面不能有sys.wait
--                 end)

--                 sys.waitUntil(_G.GPS_Ggt_Topic)     
--                 sys.waitUntil(_G.Updata_OK) 
--                 log.info("----------上传数据完毕，即将进入深度休眠-----------")
--                 mobile.flymode(0, true)--打开飞行模式
--                 pm.power(pm.USB, false) 
--                 pm.power(pm.GPS, false) 
--                 sys.wait(200)
--                 pm.dtimerStart(1,_G.deeprest_time)------------------------------休眠时间--------
--                 --pm.force(pm.DEEP)
--                 pm.power(pm.WORK_MODE,3)

--                 sys.subscribe(_G.GPS_Ggt_Topic_F,function()
--                     log.info("-----------GPS信息正在获取中......-----------")
--                     --sys.wait(1*1000)
--                 end)          
--         --end
--     end)
-- else
--     log.info("-------------------普通复位，开始运行-------------------")
--     gpio.setup(23,nil)
--     gpio.close(33) --如果功耗偏高，开始尝试关闭WAKEUPPAD1
--     --mobile.flymode(0, true)--打开飞行模式
--     --gpio.close(35) --这里pwrkey接地才需要，不接地通过按键控制的不需要
	
-- 	-- if devicemodel =="restdeep" then

-- 	    sys.taskInit(function()
-- 	        log.info("-------------------等联网完成--------------------------")
-- 	        sys.wait(6000)
-- 	        log.info("工作60秒后进入深度休眠")
-- 	        sys.wait(60*1000)
-- 	        mobile.flymode(0, true)
-- 	        sys.wait(10000)
-- 	        pm.dtimerStart(1,30*1000)
-- 	        --pm.force(pm.DEEP)
-- 	        --pm.power(pm.WORK_MODE,2)
-- 	        pm.power(pm.WORK_MODE,3)
-- 	    end)
-- 	-- end
-- end



