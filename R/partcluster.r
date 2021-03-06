#' @title Extract profiles from peak set partitions
#'
#' @export
#'
#' @description \code{partcluster} extract profiles from peak set partitions generated by \code{\link{agglomer}}.
#'
#' @param profileList A profile list.
#' @param dmass Numeric. m/z gap size
#' @param ppm Logical. \code{dmass} given in ppm?
#' @param dret Numeric. RT gap size; units equal to those of the input files
#' @param from Logical FALSE or integer. Restrict to certain partitons.
#' @param to Logical FALSE or integer. Restrict to certain partitions.
#' @param progbar Logical. Should a progress bar be shown? Only for Windows.
#' @param plotit Logical. Plot profile extraction? For debugging.
#'
#' @return Updated profile list
#' 
#' @details enviMass workflow function. Works along decreasing intensities. The remaining peak of highest intensity not
#' yet part of a profile is either assigned to an existing profile (closest in mass) or initializes a new profile. With
#' addition of a peak to a new profile, profile mass tolerances are gradually adapted.  
#' 
#' @seealso \code{\link{startprofiles}}, \code{\link{agglomer}}


partcluster<-function(
	profileList,
	dmass=3,
	ppm=TRUE,
	dret=60,
	from=FALSE,
	to=FALSE,
	progbar=FALSE,
	plotit=FALSE
){

		  ##############################################################################
		  if(!profileList[[1]][[2]]){stop("run agglom first on that profileList; aborted.")}
		  if(!is.numeric(dmass)){stop("dmass must be numeric; aborted.")}
		  if(!is.numeric(dret)){stop("dret must be numeric; aborted.")}
		  if(!is.logical(ppm)){stop("ppm must be logical; aborted.")}
		  if(!from){m=1}else{m=from}
		  if(!to){n=length(profileList[[6]][,1])}else{n=to}
		  if( (from!=FALSE) || (to!=FALSE) ){
			startat<-c(1);
			profileList[[2]][,8]<-1;
		  }else{
			startat<-c(0);
		  }
		  if(ppm){ppm2=1}else{ppm2=2};
		  ##############################################################################
		  if(progbar==TRUE){  prog<-winProgressBar("Extract time profiles...",min=m,max=n);
							  setWinProgressBar(prog, 0, title = "Extract time profiles...", label = NULL);}
		  often<-c(0);
		  atk<-c();
		  for(k in m:n){
			if(progbar==TRUE){setWinProgressBar(prog, k, title = paste("Extract time profiles for ",(profileList[[6]][k,2]-profileList[[6]][k,1]+1)," peaks",sep=""), label = NULL)}
			if(profileList[[6]][k,3]>1){
			  delmz<-(max(profileList[[2]][(profileList[[6]][k,1]:profileList[[6]][k,2]),1])-min(profileList[[2]][(profileList[[6]][k,1]:profileList[[6]][k,2]),1]))
			  if(ppm){
				delmz<-(delmz/mean(profileList[[2]][(profileList[[6]][k,1]:profileList[[6]][k,2]),1])*1E6)
			  }
			  delRT<-(max(profileList[[2]][(profileList[[6]][k,1]:profileList[[6]][k,2]),3])-min(profileList[[2]][(profileList[[6]][k,1]:profileList[[6]][k,2]),3]))
			  if( (delmz>(dmass*2)) || (delRT>dret) || (any(duplicated(profileList[[2]][(profileList[[6]][k,1]:profileList[[6]][k,2]),6]))) ){  # check dmass & dret & uniqueness
				often<-c(often+1)
				atk<-c(atk,k);
				clusters <- .Call("getProfiles",
								  as.numeric(profileList[[2]][(profileList[[6]][k,1]:profileList[[6]][k,2]),1]),       # mz
								  as.numeric(profileList[[2]][(profileList[[6]][k,1]:profileList[[6]][k,2]),3]),       # RT
								  as.numeric(profileList[[2]][(profileList[[6]][k,1]:profileList[[6]][k,2]),2]),       # intens
								  as.integer(profileList[[2]][(profileList[[6]][k,1]:profileList[[6]][k,2]),6]),       # sampleID                          
								  as.integer(order(profileList[[2]][(profileList[[6]][k,1]:profileList[[6]][k,2]),2],decreasing=TRUE)),   # intensity order
								  as.integer(order(profileList[[2]][(profileList[[6]][k,1]:profileList[[6]][k,2]),6],decreasing=FALSE)),  # sampleID order                          
								  as.numeric(dmass),
								  as.integer(ppm2),
								  as.numeric(dret),
								  as.integer(1),						  
								  PACKAGE="enviMass"
								 )
				clusters[clusters[,10]!=0,10]<-(clusters[clusters[,10]!=0,10]+startat); 
				profileList[[2]][(profileList[[6]][k,1]:profileList[[6]][k,2]),8]<-clusters[,10]
				profileList[[2]][(profileList[[6]][k,1]:profileList[[6]][k,2]),]<-(profileList[[2]][(profileList[[6]][k,1]:profileList[[6]][k,2]),][order(clusters[,10],decreasing=FALSE),])
				startat<-c(max(clusters[,10]))
				########################################################################
				if(plotit){
					profileList[[2]][(profileList[[6]][k,1]:profileList[[6]][k,2]),]<-
					profileList[[2]][(profileList[[6]][k,1]:profileList[[6]][k,2]),][
					order(profileList[[2]][(profileList[[6]][k,1]:profileList[[6]][k,2]),6]),]
					plot(
					  profileList[[2]][(profileList[[6]][k,1]:profileList[[6]][k,2]),1],
					  profileList[[2]][(profileList[[6]][k,1]:profileList[[6]][k,2]),3],
					  pch=19,xlab="m/z",ylab="RT",cex=0.5,col="lightgrey"
					)
					atID<-unique(profileList[[2]][(profileList[[6]][k,1]:profileList[[6]][k,2]),6])
					seqID<-c(1:length(profileList[[2]][(profileList[[6]][k,1]:profileList[[6]][k,2]),6]))
					for(i in 1:length(atID)){
					  if(length(seqID[profileList[[2]][(profileList[[6]][k,1]:profileList[[6]][k,2]),6]==atID[i]])>1){
						subseqID<-seqID[profileList[[2]][(profileList[[6]][k,1]:profileList[[6]][k,2]),6]==atID[i]]
						for(m in 1:(length(subseqID)-1)){
						  for(n in (m+1):length(subseqID)){
						   lines(
							  c(profileList[[2]][(profileList[[6]][k,1]:profileList[[6]][k,2]),1][subseqID[m]],profileList[[2]][(profileList[[6]][k,1]:profileList[[6]][k,2]),1][subseqID[n]]),
							  c(profileList[[2]][(profileList[[6]][k,1]:profileList[[6]][k,2]),3][subseqID[m]],profileList[[2]][(profileList[[6]][k,1]:profileList[[6]][k,2]),3][subseqID[n]]),
							  col="lightgrey",lwd=1
							)
						  }
						}
					  }
					}
					meanmass<-mean(profileList[[2]][(profileList[[6]][k,1]:profileList[[6]][k,2]),1])
					meanRT<-mean(profileList[[2]][(profileList[[6]][k,1]:profileList[[6]][k,2]),3])
					lengppm<-(as.numeric(dmass)*meanmass/1e6)
					lines(
					  c((meanmass-0.5*lengppm),(meanmass+0.5*lengppm)),
					  c(meanRT,meanRT),
					  col="blue",lwd=3
					)
					lines(
					  c(meanmass,meanmass),
					  c((meanRT-0.5*dret),(meanRT+0.5*dret)),
					  col="blue",lwd=3
					)
					clust<-profileList[[2]][(profileList[[6]][k,1]:profileList[[6]][k,2]),8]
					clust<-(clust-min(clust)+1)
					colorit<-sample(colors(),max(clust))
					points(
					  profileList[[2]][(profileList[[6]][k,1]:profileList[[6]][k,2]),1],
					  profileList[[2]][(profileList[[6]][k,1]:profileList[[6]][k,2]),3],
					  pch=19,cex=1,col=colorit[clust]
					)
					text(
					  profileList[[2]][(profileList[[6]][k,1]:profileList[[6]][k,2]),1],
					  profileList[[2]][(profileList[[6]][k,1]:profileList[[6]][k,2]),3],
					  labels=as.character(clust),
					  pch=19,cex=1,col="darkgrey"
					)
				}
				########################################################################
			}else{
				startat<-(startat+1);
				profileList[[2]][(profileList[[6]][k,1]:profileList[[6]][k,2]),8]<-startat;
			}
		}else{
		startat<-(startat+1);
		profileList[[2]][(profileList[[6]][k,1]:profileList[[6]][k,2]),8]<-startat;
		}
	}
	if(progbar==TRUE){close(prog);}
	##############################################################################
	# assemble index matrix ######################################################
	index <- .Call("indexed",
		as.integer(profileList[[2]][,8]),
		as.integer(startat),
		as.integer(17),
		PACKAGE="enviMass"
	)
	index<-index[index[,1]!=0,]
	index[,4]<-seq(1:length(index[,4]))
	colnames(index)<-c(
		"start_ID","end_ID","number_peaks_total", #1
		"profile_ID","deltaint_newest","deltaint_global", #4
		"absolute_mean_dev","blind?","above_blind?", #7
		"number_peaks_sample","number_peaks_blind", #10
		"mean_int_sample","mean_int_blind", #12
		"mean_mz","mean_RT","mean_int", #14
		"newest_intensity"#17
	)
	profileList[[7]]<-index
	##############################################################################
	# get characteristics of individual profiles #################################
	m=1
	n=length(profileList[[7]][,1])
    if(progbar==TRUE){  prog<-winProgressBar("Extract profile data...",min=m,max=n);
						setWinProgressBar(prog, 0, title = "Extract profile data...", label = NULL);}
    for(k in m:n){
		if(progbar==TRUE){setWinProgressBar(prog, k, title = "Extract profile data...", label = NULL)}
			profileList[[7]][k,14]<-mean(profileList[[2]][(profileList[[7]][k,1]:profileList[[7]][k,2]),1])
			profileList[[7]][k,15]<-mean(profileList[[2]][(profileList[[7]][k,1]:profileList[[7]][k,2]),3])	  
			profileList[[7]][k,16]<-mean(profileList[[2]][(profileList[[7]][k,1]:profileList[[7]][k,2]),2])	
	}
	if(progbar==TRUE){close(prog);}
	profileList[[1]][[3]]<-TRUE
	##############################################################################
	return(profileList)

}

