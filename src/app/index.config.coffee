angular.module 'mnoEnterpriseAngular'

  .config(($logProvider, toastrConfig) ->
    'ngInject'

    # Enable log
    $logProvider.debugEnabled true
    # Set options third-party lib
    toastrConfig.timeOut = 5000
    toastrConfig.positionClass = 'toast-top-right'
    toastrConfig.preventDuplicates = true
    toastrConfig.progressBar = true
  )

  .config(($httpProvider) ->
    'ngInject'

    $httpProvider.defaults.headers.common['Accept'] = 'application/json'
    $httpProvider.defaults.headers.common['Content-Type'] = 'application/json'

    if token = $("meta[name='csrf-token']").attr("content")
      $httpProvider.defaults.headers.common['X-CSRF-Token'] = token

    return $httpProvider
  )

  .config ($httpProvider) ->
    $httpProvider.interceptors.push ($q, $window) ->
      {
        responseError: (rejection) ->
          if rejection.status == 401
            # Redirect to login page
            console.log "User is not connected!"
            $window.location.href = '/'

          $q.reject rejection
      }

  .config(($sceDelegateProvider) ->
    'ngInject'

    # Configure SCE to authorize the Maestrano domains
    # (see: https://docs.angularjs.org/api/ng/provider/$sceDelegateProvider)
    $sceDelegateProvider.resourceUrlWhitelist([
      # Allow same origin resource loads.
      'self'
    ])
  )

  .config(($translateProvider, I18N_CONFIG) ->
    # Path to translations files
    localesFileConfig = {
      files: [
        {
          prefix: 'locales/',
          suffix: '.json'
        }
      ]
    }

    availableLocales = _.map(I18N_CONFIG.available_locales, 'id')

    $translateProvider
      .useStaticFilesLoader(localesFileConfig)
      .preferredLanguage(I18N_CONFIG.preferred_locale)

    $translateProvider
      .registerAvailableLanguageKeys(availableLocales)
      # Try to find preferred language from the browser
      .uniformLanguageTag('bcp47')
      .determinePreferredLanguage()
      .fallbackLanguage('en')

    # Interpolation configuration
    $translateProvider
      .useSanitizeValueStrategy('sanitizeParameters')
      .useMessageFormatInterpolation()

    # TODO: Activate in "developer mode" only (spams the console and makes the application lag)
    # $translateProvider.useMissingTranslationHandlerLog()

    # Force asynchronous reload to trigger translate-cloak directive
    $translateProvider.forceAsyncReload(true)
  )
