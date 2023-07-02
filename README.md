# MKV Profile

<p align="center">
<img src="assets/icons/mkv_profile.png" width="300">
</p>

Automatically manage and mux series or movie files to the common conventions used by media players and media servers.
The GUI is intentionally made simple and is designed for least user interactions by implementing per profile configuration to manage files and generate a command to be used on mkvmerge process.


## Download
 Head to [Releases](https://github.com/harlanx/mkv_profile/releases) section to download latest version
## Available Profile Configurations
- Show (Movie / Series) Title Formats
    |Data|Variable|
    |:-|:-|
    |Duration|`%duration%`|
    |Encoding|`%encoding%`|
    |Frame Rate|`%frame_rate%`|
    |Height|`%height%`|
    |Size|`%size%`|
    |Title|`%title%`|
    |Width|`%width%`|
    |Year|`%year%`|
- Video Title Formats
    |Data|Variable|
    |:-|:-|
    |Language|`%language%`|
    |Duration|`%duration%`|
    |Encoding|`%encoding%`|
    |Episode (For Series)|`%episode%`|
    |Format|`%format%`|
    |Frame Rate|`%frame_rate%`|
    |Height|`%height%`|
    |Season (For Series)|`%season%`|
    |Size|`%size%`|
    |Title|`%title%`|
    |Width|`%width%`|
    |Year|`%year%`|
- Audio Title Formats
    |Data|Variable|
    |:-|:-|
    |Language|`%language%`|
    |Format|`%format%`|
    |Bit Rate|`%bit_rate%`|
    |Channels|`%channels%`|
    |Sampling Rate|`%sampling_rate%`|
    |Default|`%default%`|
    |Original Language|`%original_language%`|
    |Forced|`%forced%`|
    |Commentary|`%commentary%`|
    |Hearing Impaired|`%hearing_impaired%`|
    |Visual Impaired|`%visual_impaired%`|
    |Text Description|`%text_description%`|
- Subtitle Title Formats
    |Data|Variable|
    |:-|:-|
    |Language|`%language%`|
    |Format|`%format%`|
    |Default|`%default%`|
    |Original Language|`%original_language%`|
    |Forced|`%forced%`|
    |Commentary|`%commentary%`|
    |Hearing Impaired|`%hearing_impaired%`|
    |Visual Impaired|`%visual_impaired%`|
    |Text Description|`%text_description%`|
- Specify the Languages to be Included
- Specifying the Subtitle Default Flag
    - Specify Which Language can be set to Default
    - Specify the Order Fallbacks of Flags that will be set as default
        - NOTE: If Default is used in the Flag Order, It will set the Default Flag to a subtitle track that doesn't have any of the available track flags set to true.
- Modifiers
    - User can specify text or regex pattern that will be replaced by another specified text or an empty text.

## Title Scanning
- **Show:** Uses folder name (if Use Folder Name is set to TRUE in Profile Configuration) or the file name of first video available from the list to be used as a source title alongside with the modifiers. Variables specified in the *Show* title format will be replaced with the corresponding data.
- **Video:** Uses the video file's name as the source title to be used alongside with the modifiers. Variables specified in the *Video* title format will be replaced with the corresponding data.
- **Audio:** Variables specified in the *Audio* title format will be replaced with the corresponding data.
- **Subtitle:** Variables specified in the *Subtitle* title format will be replaced with the corresponding data.

## Available Track Options (Video/Audio/Subtitle)
- Title
- Language
- **Flags** [Default, Original Language, Forced, Commentary, Hearing Impaired, Visual Impaired, Text Description]
- Extra Options field for [mkvmerge commands](https://mkvtoolnix.download/doc/mkvmerge.html) (Separated by space)
    - You can use the variable %id% to access the track id in the user specified extra options
    - e.g. --track-enabled-flag %id%:true --no-track-tags --no-global-tags
## Available Video Options
- No Chapters
- No Attachments
## Available Attachment Options (Chapters/Fonts/Images)
- Extra Options field for [mkvmerge commands](https://mkvtoolnix.download/doc/mkvmerge.html) (Separated by space)
    - NOTE: This option is only available for added (non-embedded) attachments.

## Detection of Movies or Series
This app assumes folders with single video file as movie, for folders that contains multiple videos — will be detected as series. If detected as series, file names will be used to assume and detect any indication of Season and Episode numbers.

## Supported Formats
**Video:** [avi, mov, mp4, mpeg, mpg, m4v, mkv]

**Audio:** [aac, flac, m4a, mp3, ogg, opus, wav]

**Subtitle:** [srt, ass, ssa]

**Chapter:** [ogm, txt, xml]

**Font:** [ttf, otf]

**Image:** [jpg, jpeg, png]

## Third Party Requirements
This app relies on the third party tools [MediaInfo](https://mediaarea.net/en/MediaInfo) and [MKVMerge](https://mkvtoolnix.download/doc/mkvmerge.html) thus required for this app to work. You can download them in their websites:
- [MediaInfo](https://mediaarea.net/en/MediaInfo/Download/Windows)
- [MKVMerge](https://mkvtoolnix.download/downloads.html#windows)