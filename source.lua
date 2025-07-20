local html = require("html")

function id() return "nightsup" end
function name() return "NightSup" end
function lang() return "en" end
function version() return 1 end

local base = "https://nightsup.net"

function fetch_manga_list(url)
	local res = http.get(url)
	local doc = html.parse(res.body)

	local mangas = {}
	for _, item in ipairs(doc:select("div.page-item-detail")) do
		local link = item:select("h3.h5 a")
		local title = link:text()
		local manga_url = link:attr("href")
		local thumb = item:select("img"):attr("data-src") or item:select("img"):attr("src")

		table.insert(mangas, {
			title = title,
			url = manga_url,
			thumbnail_url = thumb
		})
	end

	return mangas
end

function popular_manga(page)
	return fetch_manga_list(base .. "/manga/page/" .. page)
end

function latest_manga(page)
	return fetch_manga_list(base .. "/manga/page/" .. page .. "/?order=update")
end

function search_manga(search, page, filters)
	return fetch_manga_list(base .. "/page/" .. page .. "/?s=" .. search)
end

function manga_details(manga_url)
	local res = http.get(manga_url)
	local doc = html.parse(res.body)

	local title = doc:select("div.post-title h1"):text()
	local author = doc:select("div.author-content a"):text()
	local desc = doc:select("div.summary__content"):text()
	local genres = {}

	for _, g in ipairs(doc:select("div.genres-content a")) do
		table.insert(genres, g:text())
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
	for _, ch in ipairs(doc:select("ul.main li.wp-manga-chapter")) do
		local link = ch:select("a")
		table.insert(chapters, {
			title = link:text(),
			url = link:attr("href")
		})
	end

	return chapters
end

function page_list(chapter_url)
	local res = http.get(chapter_url)
	local doc = html.parse(res.body)

	local pages = {}
	for _, img in ipairs(doc:select("div.reading-content img")) do
		local src = img:attr("data-src") or img:attr("src")
		table.insert(pages, src)
	end

	return pages
end
