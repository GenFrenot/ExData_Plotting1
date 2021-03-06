#
# plot3.R is 
# 1. loading Household Power Consumption data from the web
# 2. testing the memory size that will be required for the data
# 3. subsetting to the observations of Feb 1 and 2, 2007
# 4. generating a 3-line chart on 'Global Active Power Consumption Sub-metering' 
# 5. saving the result to a file 'plot3.png' of 480x480 pixels
#
#                    
#
# to run this script, ensure the R file is placed to your working directory and use
#    source("plot3.R")
# 
# output 
#    a histogram on the screen and its copy to a 480 x 480 png file called "plot3.png"
#

# clear the environment
rm(list=ls())

# load plyr to be able to use the mutate function
library(plyr)

#
# 1. if not yet done, loading Household Power Consumption data from the web
#
if(!file.exists("household_power_consumption.txt"))
{
    print("loading Household Power Consumption data from the web...")
    #
    fileUrl <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
    download.file(fileUrl,destfile="powerconsumption.zip")
    unzip(zipfile="powerconsumption.zip")
}

#
#   2. testing the memory size that will be required for the data
#
print("testing the memory size that will be required for the data...")
#
# cutting the file in chunks of 1000 lines, how many chunks would we get?
nbchunk<-read.table(pipe('find /v /c "" household_power_consumption.txt'))[[3]] / 1000# 
# the data would fit into 2076 chunks of max 1000 lines 

# loading one chunk of 1000 lines to calculates its memory size
chunk<-read.table("household_power_consumption.txt",nrows=1000,sep=";",header=TRUE)
# calculates the memory space required in bytes
bytesrequired<-nbchunk * object.size(chunk)
print("Memory size required: ") 
print(bytesrequired, units="Mb")  
# loading the source file would use 274.7 Mb, which is feasible 
# exit if the size would be more than 500 Mb
if(bytesrequired > 500 *1024*2014)
{
    print("Too much memory required, quitting... ") 
    exit()
}

#
#   3. subsetting to the observations of Feb 1 and 2, 2007
#
print("subsetting to the observations of Feb 1 and 2, 2007...")
#
# read the entire file
alldata<-read.table("household_power_consumption.txt",sep=";",header=TRUE, na.strings = "?")
# immediately extract the data for Feb 1 and 2, 2017
data<-subset(alldata,alldata$Date=="1/2/2007"|alldata$Date=="2/2/2007")
# clear memory by deleting the large data set
rm(alldata)

# transform the Time column with values of Date class
data<-mutate(data,Time=as.POSIXct(strptime(paste(Date,Time),"%d/%m/%Y %H:%M:%S")))
# transform the Date column with values of Date class
data<-mutate(data,Date=as.Date(strptime(Date,"%d/%m/%Y")))

#
# 4. generating a 3-line chart on 'Global Active Power Consumption Sub-metering' 
#
print("generating a 3-line chart on 'Global Active Power Consumption Sub-metering' ...")
#
# set the screen as destination for the graphic generation (in my case the screen corresponds to the device 2)
dev.set(2) 
# reset the environment
plot.new()
# generate the chart on the screen 
with(data, {
       plot(Time, Sub_metering_1, type="l", col="black", xlab="", ylab="Energy sub metering")
       points(Time, Sub_metering_3, type="l", col="blue") 
       points(Time, Sub_metering_2, type="l", col="red")
	}
)
legend("topright", lty=1
        , col=c("black","blue","red")
        , legend=c("Sub_metering_1","Sub_metering_2","Sub_metering_3"))

#
# 5. saving the result to a file 'plot3.png' of 480x480 pixels
#
print("saving the result to a file 'plot3.png' of 480x480 pixels...")
#
dev.copy(png,file="plot3.png",width = 480, height = 480, units = "px")
# close the file
dev.off()
#
print("done!")

# clear the environment
rm(list=ls())