local html = require("html")
local json = require("json")

function id() return "nightsup_madara_v2" end
function name() return "NightSup v2" end
function lang() return "en" end
function version() return 1 end

local base = "https://nightsup.net"

local function parse_cards(doc)
	local mangas = {}
	for _, card in ipairs(doc:select("div.page-item-detail")) do
		local title = card:select("h3.h5 > a"):text()
		local url = card:select("h3.h5 > a"):attr("href")
		local thumb = card:select("img"):attr("src") or card:select("img"):attr("data-src")

		table.insert(mangas, {
			title = title,
			url = url,
			thumbnail_url = thumb
		})
	end
	return mangas
end

function popular_manga(page)
	local res = http.get(base .. "/manga/page/" .. page)
	local doc = html.parse(res.body)
	return parse_cards(doc)
end

function latest_manga(page)
	local res = http.get(base .. "/manga/page/" .. page .. "/?order=update")
	local doc = html.parse(res.body)
	return parse_cards(doc)
end

function search_manga(search, page, filters)
	local url = base .. "/page/" .. page .. "/?s=" .. search
	local res = http.get(url)
	local doc = html.parse(res.body)
	return parse_cards(doc)
end

function manga_details(manga_url)
	local res = http.get(manga_url)
	local doc = html.parse(res.body)

	local title = doc:select("div.post-title > h1"):text()
	local desc = doc:select("div.description-summary"):text()
	local author = doc:select("div.author-content > a"):text()
	local genres = {}

	for _, genre in ipairs(doc:select("div.genres-content a")) do
		table.insert(genres, genre:text())
	end

	return {
		title = title,
		author = author,
		description = desc,
		genres = genres,
		status = 1,
		url = manga_url
	}
end

function chapter_list(manga_url)
	local res = http.get(manga_url)
	local doc = html.parse(res.body)

	local chapters = {}
	for _, chapter in ipairs(doc:select("ul.main li.wp-manga-chapter")) do
		local a = chapter:select("a")
		table.insert(chapters, {
			title = a:text(),
			url = a:attr("href")
		})
	end
	return chapters
end

function page_list(chapter_url)
	local res = http.get(chapter_url)
	local doc = html.parse(res.body)

	local pages = {}
	for _, img in ipairs(doc:select("div.reading-content img")) do
		local src = img:attr("src") or img:attr("data-src")
		table.insert(pages, src)
	end
	return pages
end
