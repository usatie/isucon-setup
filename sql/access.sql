WITH summary AS (
	SELECT
		REGEXP_REPLACE(REGEXP_SUBSTR(time, "..:..:.. "), " ", "") as time,
		REGEXP_REPLACE(
			REGEXP_REPLACE(
				REGEXP_REPLACE(uri, "\\?.*", ""),
			".{8}-.{4}-.{4}-.{4}-.{12}", ":jia_isu_id"),
			"/assets/.*",
			"/assets/:file_name"
		) as uri,
		method,
		REGEXP_REPLACE(status, "..$", "XX") as status,
		count(*) as count,
		sum(reqtime) as sum,
		avg(reqtime) as avg
	FROM /var/log/nginx/access.log
	GROUP BY 1, 2, 3, 4
)
SELECT *, CONCAT(method, "(", status, ") ", uri) as method_status_uri
FROM summary
