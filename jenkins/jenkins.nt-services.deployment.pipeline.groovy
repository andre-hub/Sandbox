pipeline {
    agent any

    environment {
        // Project
        gitPath = "http://server/Server.git"
        solutionName = "name.sln"
        configuration =  "Integration"
        platform = "Any CPU"
        testDll = "UnitTests.dll"
        publishProfile = "Integration"
        serverUser = ""
        serverPass = ""
        serverWebSvc = "webServername"
        serverNt = "ntServerName"
        database = "DATABASENAME"
        databaseServer = "DatabaseServername"
        jenkinsWorkingDir = "${env.WORKSPACE}\\JenkinsWorkDir"
        deployDataDir = "${env.WORKSPACE}\\Deployment"
        emailTo = "deploymail@example.com"
        versionNumber = ""
        
        // build applications
        msbuild = "\"C:\\Program Files (x86)\\Microsoft Visual Studio\\2019\\Community\\MSBuild\\Current\\Bin\\MSBuild.exe\""
        nuget = "\"C:\\Program Files\\nuget.exe\""
        nunit = "\"C:\\Program Files (x86)\\NUnit.org\\nunit-console\\nunit3-console.exe\""
        sevenzip = "\"c:\\program files\\7-zip\\7z.exe\""
        gitexe = "\"c:\\program files\\git\\bin\\git.exe\""
        nugetServer = "http://nuget.server.example.com:8091/"
    }
    
    stages {
        stage('Preparation') {
            steps {
                // restore nuget packages
                // bat("${env.nuget} sources Add -Name \"NugetServerName\" -Source ${nugetServer}")
                bat("${env.nuget} restore Source/${env.solutionName}")
                bat("git config --global core.longpaths true")
            }
        }
        stage('Build') {
            steps {
                // Build with msbuild over solution-file
                bat("${env.msbuild} Source/${env.solutionName} /t:Clean,Build /p:Configuration=${env.configuration};Platform=\"${env.platform}\"")
            }
        }
        stage("Tests"){
            steps {
                echo 'testing ...'
                //bat("${env.nunit} UnitTests/bin/${env.testDll}")
                // todo:  nunit testResultsPattern: 'tests/TestResult.xml'
            }
        }
        stage("Stop services"){
            parallel {
                stage("serverNt"){
                    steps{
                        bat("powershell -command \"\$serv = get-service -computername ${env.serverSchedulerDiv} -name serverNt; if(\$serv.Status -ieq 'running') { write-output \'${env.serverNt}\\serverNt laeuft, wird beendet ...\'; stop-service -inputobject \$serv; write-output 'Dienst gestoppt.'; } else { write-output \'${env.serverNt}\\serverNt laeuft nicht!\'; }\"")
                    }
                }
            }
        }
        stage("Deploy Services"){
            parallel {
                stage("Deploy Service serverNt"){
                    steps {
                        retry(3){
                            sleep(time: 10, unit:"SECONDS")
                            bat("""
                            copy \"Output\\${env.configuration}Build\\serverNt\\*.*\" \"\\\\${env.serverNt}\" /Y
                            """)
                        }
                    }
                }
            }
        }
        stage("Database"){
            steps {
                bat("Source\\packages\\FluentMigrator.Console.3.1.3\\net461\\any\\migrate.exe -c \"Server=${env.databaseServer};Database=${env.database};Trusted_Connection=True;Connection Timeout=10;\" --provider=SqlServer -a \"Source\\bin\\${env.configuration}\\MyDatabaseUpdates.dll\" -t migrate")
            }
        }
        stage("Start services"){
            parallel {
                stage("serverNt"){
                    steps{
                        bat("sc \\\\${env.serverNt} start \"serverNt\"")
                    }
                }
            }
        }
    }    

    post {
        failure {
            mail to: "${env.emailTo}",
            subject: "[jenkins] FAILED Pipeline: ${currentBuild.fullDisplayName}",
            body: "Hello\n\nthe branch ${env.BRANCH_NAME} is not ready to deploy.\nSomething is wrong with ${env.BUILD_URL}"
        }
    }
}