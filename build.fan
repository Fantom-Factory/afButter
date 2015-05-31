using build

class Build : BuildPod {

	new make() {
		podName = "afButter"
		summary = "Helps ease HTTP requests through a stack of middleware"
		version = Version("1.1.8")

		meta	= [
			"proj.name"		: "Butter",
			"repo.tags"		: "system",
			"repo.public"	: "true"		
		]

		depends = [
			"sys  1.0", 
			"inet 1.0", 
			"web  1.0",
			"util 1.0"
		]
		
		srcDirs = [`test/`, `test/oauth-code/`, `test/oauth/`, `fan/`, `fan/public/`, `fan/public/utils/`, `fan/public/middleware/`, `fan/internal/`, `fan/internal/utils/`]
		resDirs = [`doc/`,]
	}
}
