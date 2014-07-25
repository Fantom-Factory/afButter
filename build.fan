using build

class Build : BuildPod {

	new make() {
		podName = "afButter"
		summary = "A library that helps ease HTTP requests through a stack of middleware"
		version = Version("1.0.3")

		meta	= [
			"proj.name"		: "Butter",
			"tags"			: "system",
			"repo.private"	: "true"		
		]

		depends = [
			"sys 1.0", 
			"inet 1.0", 
			"web 1.0",
			"util 1.0"
		]
		
		srcDirs = [`test/`, `test/oauth/`, `fan/`, `fan/public/`, `fan/public/utils/`, `fan/public/oauth/`, `fan/public/middleware/`, `fan/internal/`, `fan/internal/utils/`]
		resDirs = [,]
	}
}
