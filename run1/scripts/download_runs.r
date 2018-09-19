#!/usr/bin/Rscript

# tasks: 208
num_tasks = 208
key = "/9TvU+JTNaadULoXjBMLb/O+fTciOYygh08EQVPWLgwguinHSZ0mKsoPc/dqbVwzUK8yBsVYLvwreZwTTzTflA=="
jobfolder = "job-49b49ee8-6b22-427e-b0e2-d7dc44a794d1"

get_completed_tasks = function(folder){
    completed = dir(folder, pattern="[0-9]")
    completed = sort(as.numeric(completed))
    return(completed)
    }


download_task = function(task, folder){
    args = paste0(
    " download",
    " --local-path ", folder,
    " --remote-path ", file.path(jobfolder, task, ""),
    " --storage-account stormacs1",
    " --storage-account-key ", key,
    " --progress-bar")
    cat("Call:\n", paste("blobxfer", args), "\n")
    err = system2("blobxfer", args)
    if(err != 0){
        unlink(file.path(folder, task), recursive=TRUE)
        stop("Encountered error during processing task.\n Error code: ", err)
        }
    
    }

main = function(folder){
    tasks = 0:(num_tasks-1)

    completed = get_completed_tasks(folder)

    for(task in tasks){
        cat("Processing task: ", task, "\n")
        if(task %in% completed){
            cat("Task was already downloaded, skipping!\n")
            } else {
            cat("Downloading task number: ", task, "\n")
            download_task(task, folder)
            }
        }
    }



if(!interactive()){
    folder = "azure_output"
    main(folder)
    }
