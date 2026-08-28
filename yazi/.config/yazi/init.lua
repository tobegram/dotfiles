-- ~/.config/yazi/init.lua
-- Custom preview handler for images with mediainfo metadata overlay

local M = {}

-- Configuration
local config = {
	max_metadata_lines = 20,      -- Max lines of metadata to show
	show_filename      = true,   -- Show filename in metadata section
	show_dimensions    = true,   -- Show image dimensions prominently
	show_date          = true,   -- Show modification date
}

-- Check if file is an image
local function is_image(path)
	local ext = path:match("%.(%w+)$")
	if not ext then return false end
	ext = ext:lower()
	local image_exts = {
		["jpg"] = true, ["jpeg"] = true, ["png"] = true,
		["gif"] = true, ["webp"] = true, ["bmp"] = true,
		["tiff"] = true, ["tif"] = true, ["avif"] = true,
		["heic"] = true, ["heif"] = true, ["jxl"] = true,
		["svg"] = true, ["ico"] = true,
	}
	return image_exts[ext] or false
end

-- Extract key metadata from mediainfo output
local function parse_medainfo(output)
	local metadata = {
		dimensions = "",
		format     = "",
		size       = "",
		date       = "",
		other      = {},
	}
	
	for line in output:gmatch("[^\r\n]+") do
		-- Dimensions (Width x Height)
		if line:match("Width%s*:") then
			local w = line:match("Width%s*:%s*(%d+)")
			local h = line:match("Height%s*:%s*(%d+)")
			if w and h then
				metadata.dimensions = string.format("%sx%s px", w, h)
			end
		end
		
		-- Format
		if line:match("Format%s*:") then
			metadata.format = line:match("Format%s*:%s*(.+)$"):gsub("^%s*(.-)%s*$", "")
		end
		
		-- File size
		if line:match("FileSize%s*:") then
			metadata.size = line:match("FileSize%s*:%s*(.+)$"):gsub("^%s*(.-)%s*$", "")
		end
		
		-- Modification date
		if line:match("Date%-creation%s*:") or line:match("CreateDate%s*:") then
			metadata.date = line:match("(%d%d%d%d%-%d%d%-%d%d)")
		end
		
		-- Bit depth / Color space
		if line:match("Bits/(Pixel|Sample)") then
			table.insert(metadata.other, line:match(":%s*(.+)$"))
		end
	end
	
	return metadata
end

-- Run command and capture output
local function run_cmd(cmd)
	local handle = io.popen(cmd .. " 2>&1")
	if not handle then return nil end
	local output = handle:read("*a")
	handle:close()
	return output
end

-- Main preview function for custom image handler
function M.image_preview(context)
	local path = context.files[1]:absolute()
	
	if not is_image(path) then
		return nil  -- Let default handler take over
	end
	
	local output_lines = {}
	
	-- Header with filename
	if config.show_filename then
		local filename = path:match("([^/]+)$")
		table.insert(output_lines, string.format("📁 %s", filename))
		table.insert(output_lines, string.rep("─", math.min(60, ya.get_term_cols())))
	end
	
	-- Get mediainfo
	local mediainfo_out = run_cmd(string.format("mediainfo --Output=Basic '%s'", path))
	if mediainfo_out then
		local meta = parse_medainfo(mediainfo_out)
		
		-- Show dimensions prominently
		if config.show_dimensions and meta.dimensions ~= "" then
			table.insert(output_lines, string.format("📐 %s", meta.dimensions))
		end
		
		-- Show format
		if meta.format ~= "" then
			table.insert(output_lines, string.format("🎨 Format: %s", meta.format))
		end
		
		-- Show file size
		if meta.size ~= "" then
			table.insert(output_lines, string.format("💾 Size: %s", meta.size))
		end
		
		-- Show date
		if config.show_date and meta.date ~= "" then
			table.insert(output_lines, string.format("📅 Created: %s", meta.date))
		end
		
		-- Additional metadata
		for _, item in ipairs(meta.other) do
			if #output_lines < 10 then  -- Limit total lines
				table.insert(output_lines, string.format("• %s", item))
			end
		end
	else
		table.insert(output_lines, "⚠️  Could not read metadata (mediainfo not installed?)")
	end
	
	-- Separator
	table.insert(output_lines, string.rep("─", math.min(60, ya.get_term_cols())))
	
	-- Image preview instruction (let Yazi handle actual image rendering below)
	local max_lines = config.max_metadata_lines
	table.insert(output_lines, string.format("↓ Image preview below (first %d metadata lines shown)", max_lines))
	
	return table.concat(output_lines, "\n")
end

-- Plugin registration
function M.setup()
	-- Register custom previewer for images
	ya.register_previewer("custom_image", function(context)
		return M.image_preview(context)
	end)
	
	-- Log setup completion
	ya.log("Custom image previewer loaded successfully", "info")
end

return M