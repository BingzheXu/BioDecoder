**BioDecoder — A Global Platform for Biosignal Classification and Interpretation**

**Project Overview**
The BioDecoder is a global platform designed for decoding and classifying biosignals from any biological source. It enables automated classification and physiological interpretation of electrophysiological signals, allowing researchers to align their experimental data with a unified global standard for cross-laboratory and cross-system comparability.
________________________________________
**Key Features**
•	Global Unified Classification System:
Each type of biosignal peak is assigned a unique and permanent ID, ensuring comparability and consistency across laboratories worldwide.
•	Biological Significance Annotation:
Integrates experimental data and published research from multiple contributors to establish clear physiological and pharmacological meanings for each waveform class.
•	Dynamic Updates & Open Collaboration:
Researchers can contribute new signal types to continuously refine and expand the global biosignal knowledge base, promoting shared scientific advancement.
•	Standardized Data Format:
Input file: merged_peak_library.mat
Output file: Classified_Peaks.mat
Sampling rate: 3000 Hz — ensuring data uniformity and reproducibility across all studies.
________________________________________
**Applications**
•	Biosignal classification and identification
•	Drug screening and mechanism exploration
•	Physiological signal modeling and cross-lab comparison
•	Analysis of system-specific biological signals
________________________________________
**Usage Instructions**
1.	Preparation:
Download the latest version of Class_Library_update to access the most recent classification categories and biological significance annotations.
2.	Operation:
Perform peak extraction on your own biosignal data and save the results in the standardized format as merged_peak_library.mat. If peak extraction is challenging, please contact the author for technical assistance. The file must include the following fields:
o	FileName – name of the original data file
o	Channel – channel index (starting from 1)
o	Peak – the peak index within the channel
o	Locations – time sequence (in seconds, sampling rate = 3000 Hz)
o	Voltage – corresponding voltage values (unit consistent across all data)
The file can then be directly imported into the BioDecoder for unified classification and biological interpretation.
3.	Output:
The system generates Classified_Peaks.mat, where each peak is assigned a unique ClassLabel ID.
This ID can be directly cited in publications as:
“BioDecoder Library (From Icey in SYSU), Class X peak.”
4.	Support:
If peak extraction is challenging, please contact the author for technical assistance.
________________________________________
**Citation**
When using this library and associated code, please cite:
“BioDecoder Library (From Icey in SYSU), Class X peak”
________________________________________
**Collaboration & Contribution**
Researchers are warmly invited to contact the author (xubzh5@mail.sysu.edu.cn) to collaboratively improve and expand the public biosignal classification library, advancing global standards for signal decoding and biological annotation.
(This project aims to enhance biosignal decoding efficiency and ensure reproducibility across laboratories through standardized classification and data sharing.)
📧 Contact: xubzh5@mail.sysu.edu.cn
________________________________________
**Notes**
1.	**Due to the large size of the library and input/output files, they cannot be uploaded to GitHub at this stage. Researchers interested in accessing the full BioDecoder Library and related data files are encouraged to contact the corresponding author. The resources will be made publicly available on a suitable hosting platform as soon as possible.**
2.	Always use the latest version of Class_Library_update, which contains the most up-to-date categories and biological annotations. The system integrates data from various researchers and biological models to build a unified physiological interpretation database, facilitating accurate signal decoding.
3.	If your classification results contain a large number of unsorted classes, please contact the author for troubleshooting.
4.	Users can directly reference waveform classes described in published literature for further drug screening and mechanistic studies, ensuring transparent and comparable research outcomes. When publishing, cite as:
“BioDecoder Library (From Icey in SYSU), Class X peak.”
