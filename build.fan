using build

class Build : BuildPod {

	new make() {
		podName = "afButter"
		summary = "Helps ease HTTP requests through a stack of middleware"
		version = Version("1.2.10")

		meta	= [
			"pod.dis"		: "Butter",
			"repo.tags"		: "system, web",
			"repo.public"	: "true"		
		]

		depends = [
			"sys  1.0.69 - 1.0", 
			"inet 1.0.69 - 1.0", 
			"web  1.0.69 - 1.0",
			"util 1.0.69 - 1.0"
		]

		srcDirs = [`fan/`, `fan/internal/`, `fan/internal/utils/`, `fan/public/`, `fan/public/middleware/`, `fan/public/utils/`, `test/`, `test/oauth/`, `test/oauth-code/`]
		resDirs = [`doc/`,]
	}
}
