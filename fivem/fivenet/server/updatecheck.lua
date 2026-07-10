local repo_owner = "fivenet-app"
local repo_name  = "plugins"

local checkIntervalMs = 6 * 60 * 60 * 1000 -- every 6h

local function logInfo(msg) print(("^2[FiveNet]^7 %s"):format(msg)) end
local function logError(msg) print(("^1[FiveNet]^7 %s"):format(msg)) end

-- GitHub Latest Releases API Check
local function checkForUpdate()
    local current = GetCurrentResourceVersion()
    local url = ("https://api.github.com/repos/%s/%s/releases/latest"):format(repo_owner, repo_name)

    local headers = {
        ["User-Agent"] = "fivenet-plugins-fivem-updatecheck",
        ["Accept"] = "application/vnd.github+json",
    }

    PerformHttpRequest(url, function(status, body)
        if status ~= 200 or not body then
            -- quiet fail; don't spam logs, don't block startup
            return
        end

        local ok, data = pcall(function() return json.decode(body) end)
        if not ok or type(data) ~= "table" then
            logError("Failed to parse GitHub API response.")
            return
        end

		-- Ignore if draft or prerelease
        if data.draft or data.prerelease then
            return
        end

        local tag   = data.tag_name or data.name or ""
        local html  = data.html_url or ("https://github.com/%s/%s/releases"):format(repo_owner, repo_name)
        local notes = (data.body and data.body:sub(1, 200)) or ""

        local latest = SanitizeVersion(tag)
        if CompareSemVer(latest, current) > 0 then
            logInfo(("New release available: ^5%s^7 (current ^5%s^7)"):format(latest, current))
            logInfo(("Get it here: %s"):format(html))
            if notes ~= "" then
                logInfo(("Notes: %s%s"):format(notes, (#data.body or 0) > 200 and "..." or ""))
            end
        end
    end, "GET", "", headers)
end

if Config.UpdateCheck then
	-- Start the update check (if enabled) after a delay and then periodically
	CreateThread(function()
		Wait(7500)
		checkForUpdate()

		while true do
			Wait(checkIntervalMs)
			checkForUpdate()
		end
	end)
end
