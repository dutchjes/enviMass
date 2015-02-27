#' @title Thermo .raw file conversion and centroidization with ProteoWizard (PW)
#'
#' @export
#'
#' @description \code{PWfile} calls PW msconvert
#'
#' @param rawfile Path to raw file
#' @param folderout Path to output folder
#' @param msconvert_path Path to PW msconvert executable (including \\msconvert).
#' @param notintern Ignore
#' @param use_format Output format
#' 
#' @details  enviMass workflow function. PW (not just msconvert) needs to be installed seperately, including the vendor library.
#' 


PWfile <-
function(rawfile,folderout,msconvert_path,notintern=FALSE,use_format="mzXML"){

      ##########################################################################
      # checks & setups ########################################################
      if(nchar(Sys.which("msconvert")[[1]])==0){
        cat("msconvert not in system path - ok if msconvert_path correct")
      }
      if(
          sum(substr(rawfile,nchar(rawfile)-3,nchar(rawfile))!=".RAW",substr(rawfile,nchar(rawfile)-3,nchar(rawfile))!=".raw")!=1
      ){stop("rawfile not a .RAW file")}	  
      ##########################################################################
      # convert ################################################################
      there2<-paste(" -o ",shQuote(folderout),sep="")
	  filtered0<-paste(shQuote("--"),use_format,sep="")
	  filtered1<-paste(shQuote("--32"),sep="")
	  filtered2<-paste(shQuote("--zlib"),sep="")
      filtered3<-paste(" --filter ",shQuote("peakPicking true 1-2"),sep="")
      filtered4<-paste(" --filter ",shQuote("msLevel 1"),sep="")
      system(
              paste(
                shQuote(msconvert_path),
                shQuote(rawfile),
				filtered1,
				filtered2,
				filtered0,
                filtered3,
                filtered4,
                there2
              )
      ,intern=notintern)
      ##########################################################################

}
