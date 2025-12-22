#lang scribble/manual

@(require (for-label racket/base
                     racket/contract
                     sdl3))

@title[#:tag "audio" #:style 'quiet]{Audio}

This section covers audio playback using SDL3's stream-based audio model.

SDL3 uses a stream-based audio model:
@itemlist[
  @item{Open an audio device (or use the default)}
  @item{Create audio streams with source/destination formats}
  @item{Bind streams to devices}
  @item{Push audio data into streams}
  @item{SDL automatically mixes and plays}
]

@section{Audio Specs}

Audio specs describe the format of audio data.

@defproc[(make-audio-spec [format exact-nonnegative-integer?]
                          [channels exact-positive-integer?]
                          [freq exact-positive-integer?]) SDL_AudioSpec?]{
  Creates an audio spec.

  @racket[format] is one of:
  @itemlist[
    @item{@racket[SDL_AUDIO_U8] --- Unsigned 8-bit}
    @item{@racket[SDL_AUDIO_S8] --- Signed 8-bit}
    @item{@racket[SDL_AUDIO_S16] --- Signed 16-bit}
    @item{@racket[SDL_AUDIO_S32] --- Signed 32-bit}
    @item{@racket[SDL_AUDIO_F32] --- 32-bit float}
  ]

  @racket[channels] is 1 for mono, 2 for stereo.

  @racket[freq] is the sample rate in Hz (e.g., 44100, 48000).

  @codeblock|{
    (define spec (make-audio-spec SDL_AUDIO_S16 2 44100))
  }|
}

@defproc[(audio-spec-format [spec SDL_AudioSpec?]) exact-nonnegative-integer?]{
  Returns the audio format.
}

@defproc[(audio-spec-channels [spec SDL_AudioSpec?]) exact-nonnegative-integer?]{
  Returns the channel count.
}

@defproc[(audio-spec-freq [spec SDL_AudioSpec?]) exact-nonnegative-integer?]{
  Returns the sample rate.
}

@section{Device Enumeration}

@defproc[(audio-playback-devices) (listof (cons/c exact-nonnegative-integer? string?))]{
  Returns a list of available playback devices.

  Each element is @racket[(cons device-id device-name)].

  @codeblock|{
    (for ([dev (audio-playback-devices)])
      (printf "Device ~a: ~a~n" (car dev) (cdr dev)))
  }|
}

@defproc[(audio-recording-devices) (listof (cons/c exact-nonnegative-integer? string?))]{
  Returns a list of available recording devices.
}

@defproc[(audio-device-name [device-id exact-nonnegative-integer?]) (or/c string? #f)]{
  Returns the name of an audio device.
}

@section{Device Management}

@defproc[(open-audio-device [device-id (or/c exact-nonnegative-integer? #f) #f]
                            [spec (or/c SDL_AudioSpec? #f) #f])
         exact-nonnegative-integer?]{
  Opens an audio device.

  If @racket[device-id] is @racket[#f], opens the default playback device.
  If @racket[spec] is @racket[#f], uses the system default format.

  Returns the device ID.

  @codeblock|{
    ;; Open default device with default format
    (define dev (open-audio-device))

    ;; Open default device with specific format
    (define spec (make-audio-spec SDL_AUDIO_S16 2 44100))
    (define dev2 (open-audio-device #f spec))
  }|
}

@defproc[(close-audio-device! [device exact-nonnegative-integer?]) void?]{
  Closes an audio device.
}

@defproc[(pause-audio-device! [device exact-nonnegative-integer?]) void?]{
  Pauses audio playback on a device.
}

@defproc[(resume-audio-device! [device exact-nonnegative-integer?]) void?]{
  Resumes audio playback on a device.
}

@defproc[(audio-device-paused? [device exact-nonnegative-integer?]) boolean?]{
  Returns @racket[#t] if the device is paused.
}

@defproc[(audio-device-format [device-id exact-nonnegative-integer?
                                         SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK])
         (values SDL_AudioSpec? exact-nonnegative-integer?)]{
  Returns the audio format and buffer size for a device.
}

@defproc[(audio-device-gain [device-id exact-nonnegative-integer?]) real?]{
  Returns the current device gain (volume multiplier).
}

@defproc[(set-audio-device-gain! [device-id exact-nonnegative-integer?]
                                  [gain real?]) void?]{
  Sets the device gain. 1.0 is normal volume.
}

@section{Audio Streams}

Audio streams handle format conversion and buffering.

@defproc[(make-audio-stream [src-spec SDL_AudioSpec?]
                            [dst-spec (or/c SDL_AudioSpec? #f) #f]) cpointer?]{
  Creates an audio stream.

  If @racket[dst-spec] is @racket[#f], uses the same format as the source.

  @codeblock|{
    (define src-spec (make-audio-spec SDL_AUDIO_S16 2 44100))
    (define stream (make-audio-stream src-spec))
  }|
}

@defproc[(open-audio-device-stream [device-id exact-nonnegative-integer?
                                              SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK]
                                   [spec (or/c SDL_AudioSpec? #f) #f]
                                   [#:callback callback (or/c procedure? #f) #f]
                                   [#:userdata userdata any/c #f]) cpointer?]{
  Opens a device and creates a bound stream in one call.

  The device starts paused. Call @racket[resume-audio-stream-device!] to start.

  If @racket[callback] is provided, it will be called when the stream needs data.
  The callback can accept 2, 3, or 4 arguments:
  @itemlist[
    @item{4 args: @racket[(userdata stream additional-bytes total-bytes)]}
    @item{3 args: @racket[(stream additional-bytes total-bytes)]}
    @item{2 args: @racket[(additional-bytes total-bytes)]}
  ]

  @codeblock|{
    ;; Simple device+stream setup
    (define stream (open-audio-device-stream))
    (resume-audio-stream-device! stream)
  }|
}

@defproc[(destroy-audio-stream! [stream cpointer?]) void?]{
  Destroys an audio stream.
}

@defproc[(audio-stream-device [stream cpointer?]) exact-nonnegative-integer?]{
  Returns the device ID associated with a stream.
}

@defproc[(bind-audio-stream! [device exact-nonnegative-integer?]
                             [stream cpointer?]) void?]{
  Binds a stream to a device.
}

@defproc[(unbind-audio-stream! [stream cpointer?]) void?]{
  Unbinds a stream from its device.
}

@defproc[(pause-audio-stream-device! [stream cpointer?]) void?]{
  Pauses the device associated with a stream.
}

@defproc[(resume-audio-stream-device! [stream cpointer?]) void?]{
  Resumes the device associated with a stream.
}

@defproc[(audio-stream-device-paused? [stream cpointer?]) boolean?]{
  Returns @racket[#t] if the stream's device is paused.
}

@section{Stream Operations}

@defproc[(audio-stream-put! [stream cpointer?]
                            [data cpointer?]
                            [length exact-nonnegative-integer?]) void?]{
  Adds audio data to a stream.

  @racket[data] is a pointer to the audio data.
  @racket[length] is the number of bytes.
}

@defproc[(audio-stream-available [stream cpointer?]) exact-nonnegative-integer?]{
  Returns the number of bytes available in the stream.
}

@defproc[(audio-stream-clear! [stream cpointer?]) void?]{
  Clears all buffered data from the stream.
}

@defproc[(audio-stream-flush! [stream cpointer?]) void?]{
  Flushes pending data through format conversion.
}

@defproc[(play-audio! [stream cpointer?]
                      [data cpointer?]
                      [length exact-nonnegative-integer?]) void?]{
  Convenience function that puts data into a stream.

  Same as @racket[audio-stream-put!].
}

@section{WAV Loading}

@defproc[(load-wav [source (or/c string? path? bytes? input-port?)])
         (values SDL_AudioSpec? cpointer? exact-nonnegative-integer?)]{
  Loads a WAV file.

  Returns @racket[(values audio-spec audio-data length)].

  The @racket[audio-data] pointer must be freed with @racket[free-audio-data!].

  @codeblock|{
    (define-values (spec data len) (load-wav "sound.wav"))

    ;; Play the sound
    (audio-stream-put! stream data len)

    ;; Free when done
    (free-audio-data! data)
  }|
}

@defproc[(free-audio-data! [data cpointer?]) void?]{
  Frees audio data returned by @racket[load-wav].
}

@section{Audio Mixing and Conversion}

@defproc[(mix-audio! [dst cpointer?]
                     [src cpointer?]
                     [format exact-nonnegative-integer?]
                     [length exact-nonnegative-integer?]
                     [volume real? 1.0]) void?]{
  Mixes audio data from @racket[src] into @racket[dst].

  @racket[volume] is a multiplier (1.0 = full volume).
}

@defproc[(convert-audio-samples [src-spec SDL_AudioSpec?]
                                 [src-data cpointer?]
                                 [src-length exact-nonnegative-integer?]
                                 [dst-spec SDL_AudioSpec?])
         (values cpointer? exact-nonnegative-integer?)]{
  Converts audio samples between formats.

  Returns @racket[(values dst-data dst-length)].

  The returned data must be freed with @racket[free-audio-data!].
}

@defproc[(audio-format-name [format exact-nonnegative-integer?]) string?]{
  Returns a human-readable name for an audio format.
}

@section{Audio Format Constants}

@defthing[SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK exact-nonnegative-integer?]{
  The default playback device ID.
}

@defthing[SDL_AUDIO_DEVICE_DEFAULT_RECORDING exact-nonnegative-integer?]{
  The default recording device ID.
}

@defthing[SDL_AUDIO_U8 exact-nonnegative-integer?]{
  Unsigned 8-bit audio format.
}

@defthing[SDL_AUDIO_S8 exact-nonnegative-integer?]{
  Signed 8-bit audio format.
}

@defthing[SDL_AUDIO_S16 exact-nonnegative-integer?]{
  Signed 16-bit audio format (most common for CD-quality audio).
}

@defthing[SDL_AUDIO_S32 exact-nonnegative-integer?]{
  Signed 32-bit audio format.
}

@defthing[SDL_AUDIO_F32 exact-nonnegative-integer?]{
  32-bit floating point audio format.
}

@section{Example: Playing a Sound}

Here's a complete example of loading and playing a WAV file:

@codeblock|{
#lang racket/base
(require sdl3)

(with-sdl
  ;; Initialize audio
  (sdl-init! 'audio)

  ;; Open default audio device and stream
  (define stream (open-audio-device-stream))

  ;; Load a WAV file
  (define-values (spec data len) (load-wav "sound.wav"))

  ;; Start audio playback
  (resume-audio-stream-device! stream)

  ;; Play the sound
  (audio-stream-put! stream data len)

  ;; Wait for sound to finish
  (let loop ()
    (when (> (audio-stream-available stream) 0)
      (delay! 100)
      (loop)))

  ;; Cleanup
  (free-audio-data! data)
  (destroy-audio-stream! stream))
}|
