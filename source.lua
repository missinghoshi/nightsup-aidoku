local html = require("html")
local json = require("json")

function id() return "nightsup" end
function name() return "NightSup" end
function lang() return "en" end
function version() return 1 end

local base = "https://nightsup.net"

function popular_manga(page)
	local url = base .. "/series/?page=" .. page
	local res = http.get(url)
	local doc = html.parse(res.body)

	local mangas = {}
	for _, card in ipairs(doc:select("div.bs > div.bsx")) do
		local title = card:select("a"):attr("title")
		local url = card:select("a"):attr("href")
		local thumb = card:select("img"):attr("src")

		table.insert(mangas, {
			title = title,
			url = url,
			thumbnail_url = thumb
		})
	end

	return mangas
end

function latest_manga(page)
	return popular_manga(page) -- Same layout
end

function search_manga(search, page, filters)
	local url = base .. "/page/" .. page .. "/?s=" .. search
	local res = http.get(url)
	local doc = html.parse(res.body)

	local mangas = {}
	for _, card in ipairs(doc:select("div.bs > div.bsx")) do
		local title = card:select("a"):attr("title")
		local url = card:select("a"):attr("href")
		local thumb = card:select("img"):attr("src")

		table.insert(mangas, {
			title = title,
			url = url,
			thumbnail_url = thumb
		})
	end

	return mangas
end

function manga_details(manga_url)
	local res = http.get(manga_url)
	local doc = html.parse(res.body)

	local title = doc:select("h1.entry-title"):text()
	local desc = doc:select("div.entry-content > p"):first():text()
	local author = ""
	local genres = {}

	for _, el in ipairs(doc:select("div.genres a")) do
		table.insert(genres, el:text())
	end

	return {
		title = title,
		author = author,
		description = desc,
		genres = genres,
		status = 1, -- unknown
		url = manga_url
	}
end

function chapter_list(manga_url)
	local res = http.get(manga_url)
	local doc = html.parse(res.body)

	local chapters = {}
	for _, li in ipairs(doc:select("ul.main li")) do
		local link = li:select("a")
		local title = link:text()
		local url = link:attr("href")

		table.insert(chapters, {
			title = title,
			url = url
		})
	end

	return chapters
end

function page_list(chapter_url)
	local res = http.get(chapter_url)
	local doc = html.parse(res.body)

	local pages = {}
	for _, img in ipairs(doc:select("div.reader-area img")) do
		local src = img:attr("src")
		table.insert(pages, src)
	end

	return pages
end
