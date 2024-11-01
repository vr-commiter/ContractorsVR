
local json = require "json"
local base64 = require "base64"


local _cur = 0
local _appId = 0
local _apiKey = 0
local _isRegistered = false
local _seek_objs = {
}

local function make_request(method, body)
    local jSONObject = {}
    jSONObject["Method"] = method;
    jSONObject["Body"] = base64.encode(body);
    jSONObject["ReqId"] = _cur;

    _cur = _cur + 1
    local str = json.encode(jSONObject);
    print( "make_req", str, "\n")
    return str;
end

local function register_app()
    local req = make_request("register_app", _appId .. ";" .. _apiKey);
    websocket_send(req);
end

local function play_effect_by_content(obj)
    if not websocket_status()   or not _isRegistered then
        return 
    end

    local body = json.encode(obj)
    local req = make_request("play_effect_by_content", body);
    websocket_send(req);
end

local function seek_by_uuid(uuid)
    _seek_objs[uuid] = true
    if not websocket_status()   or not _isRegistered then
        return 
    end

    local req = make_request("seek_by_uuid", _appId .. ";" .. uuid);
    websocket_send(req);
end

local function play_effect_by_uuid(uuid)
    if not websocket_status()   or not _isRegistered then
        return 
    end

    local req = make_request("play_effect_by_uuid", _appId .. ";" .. uuid);
    websocket_send(req);
end

local function _update_loop()
    if not websocket_status() then
        websocket_init()
        return false
    end

    local tab = websocket_receive_message()
	for k,v in pairs(tab or {}) do
        print("" .. k .. "" .. ": " .. v)
        local msg = json.decode(v)
        if msg.Method == "register_app" then
            _isRegistered = true
            for k_,v_ in pairs(_seek_objs) do
                seek_by_uuid(k_)
            end
        end

        if msg.Method == "seek_by_uuid" then
            local obj_str = base64.decode(msg.Result)
            local obj = json.decode(obj_str)
            _seek_objs[obj.name] = obj
        end
    end

    if not _isRegistered then
        register_app()
        return false
    end
    return false -- Loops forever
end

local function _init(appId, apiKey)
    _appId = appId
    _apiKey = apiKey

    _update_loop()
    LoopAsync(5000, _update_loop)
end

local function _find_effect(uuid)
    return _seek_objs[uuid]
end

return {
    init = _init,
    play_effect_by_content = play_effect_by_content,
    seek_by_uuid = seek_by_uuid,
    play_effect_by_uuid = play_effect_by_uuid,
    find_effect = _find_effect,
}