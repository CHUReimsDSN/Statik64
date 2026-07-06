module Statik64
    module CLI
        class UtilManager

            UTILS_FOLDER = Rails.root.freeze # TODO
            NOTIFY_OPTION = 'notify_utils'.freeze
            STRING_OPTION = 'string_utils'.freeze
            UI_BIND_OPTION = 'ui_bind'.freeze
            FORM_RULES_OPTION = 'form_rules_utils'.freeze
            DOCUMENT_UTILS_OPTION = 'document_utils'.freeze
            DATE_UTILS_OPTION = 'date_utils'.freeze
            USE_CABLE_OPTION = 'use_cable'.freeze

            def self.write_files(option_values)
                filenames = []
                option_values.each do |value|
                    case value
                    when NOTIFY_OPTION
                        filenames << self.write_notify_utils
                        next
                    when STRING_OPTION
                        filenames << self.write_string_utils
                        next
                    when UI_BIND_OPTION
                        filenames << self.write_ui_binds
                        next
                    when FORM_RULES_OPTION
                        filenames << self.write_form_rules
                        next
                    when DOCUMENT_UTILS_OPTION
                        filenames << self.write_document_utils
                        next
                    when DATE_UTILS_OPTION
                        filenames << self.write_date_utils
                        next
                    when USE_CABLE_OPTION
                        filenames << self.write_use_cable
                        next
                    end
                end
                filenames
            end

            def self.get_options
                [
                    {
                        label: 'Notify Utils',
                        value: NOTIFY_OPTION,
                    },
                    {
                        label: 'String Utils',
                        value: STRING_OPTION,
                    },
                    {
                        label: 'UI Binds Utils',
                        value: UI_BIND_OPTION,
                    },
                    {
                        label: 'Form Rules Utils',
                        value: FORM_RULES_OPTION,
                    },
                    {
                        label: 'Document Utils',
                        value: DOCUMENT_UTILS_OPTION,
                    },
                    {
                        label: 'Date Utils',
                        value: DATE_UTILS_OPTION,
                    },
                    {
                        label: 'UseCable',
                        value: USE_CABLE_OPTION,
                    },
                ]
            end

            def self.write_notify_utils
                filename = 'notify-utils.ts'
                content = """
import { Notify, type QNotifyCreateOptions } from 'quasar';

const TIMEOUT_MS = 3000;

function positive(message: string, options?: QNotifyCreateOptions) {
  Notify.create({
    type: 'positive',
    message,
    timeout: TIMEOUT_MS,
    ...options,
  });
}

function negative(message: string, options?: QNotifyCreateOptions) {
  Notify.create({
    type: 'negative',
    message,
    timeout: TIMEOUT_MS,
    ...options,
  });
}

function warning(message: string, options?: QNotifyCreateOptions) {
  Notify.create({
    type: 'warning',
    message,
    timeout: TIMEOUT_MS,
    ...options,
  });
}

export const NotifyUtils = {
  positive,
  negative,
  warning,
};
                """
                File.write(filename, content)
                filename
            end

            def self.write_string_utils
                filename = 'string-utils.ts'
                content = """
function beautifyString(value: string) {
  if (!value) {
    return '';
  }
  const withCapital = value.charAt(0).toUpperCase() + value.slice(1);
  const withSpaces = withCapital.replace(/([a-z])([A-Z])/g, '$1 $2');
  return withSpaces
    .replace(/\b([A-Z])/g, (_match, letter, offset) =>
      offset === 0 ? letter : letter.toLowerCase(),
    )
    .replaceAll('_', '')
    .replaceAll('.', '')
    .replaceAll('::', ' : ');
}

export const StringUtils = {
  beautifyString,
};
                """
                File.write(filename, content)
                filename
            end

            def self.write_ui_binds
                filename = 'ui-binds.ts'
                content = """
import {
  Dark,
  type QCardProps,
  type QSpinnerProps,
  type QBtnProps,
  type QIconProps,
  type QInputProps,
  type QSelectProps,
  type QTabPanelProps,
  type QTabPanelsProps,
  type QTabProps,
  type QTabsProps,
  type QToggleProps,
  type QCheckboxProps,
  type QRangeProps,
  type QChipProps,
  type QImgProps,
  type QTableProps,
  type QBadgeProps,
  type QMenuProps,
  type QListProps,
  type QDialogProps,
} from 'quasar';

type TPropsWithClass = {
  class: string;
};

const btnRegular: QBtnProps = Object.freeze({
  noCaps: true,
  color: 'secondary',
  size: 'md',
  ripple: false,
});
const btnPositiveSmall: QBtnProps = Object.freeze({
  noCaps: true,
  color: 'positive',
  size: '0.75rem',
  ripple: false,
});
const btnWarning: QBtnProps = Object.freeze({
  ...btnRegular,
  color: 'warning',
});
const btnNegative: QBtnProps = Object.freeze({
  ...btnRegular,
  color: 'negative',
});
const btnPositive: QBtnProps = Object.freeze({
  ...btnRegular,
  color: 'positive',
});
const btnMisc: QBtnProps = Object.freeze({
  ...btnRegular,
  flat: true,
});
const btnIcon: QIconProps = Object.freeze({
  size: '1.4rem',
});
const tabs: QTabsProps & TPropsWithClass = Object.freeze({
  indicatorColor: 'white',
  activeColor: 'secondary',
  activeBgColor: 'white',
  align: 'justify',
  narrowIndicator: true,
  noCaps: true,
  dense: true,
  contentClass: 'shadow-3',
  class: 'bg-grey-4',
});
const tab: QTabProps = Object.freeze({
  ripple: false,
});
const card: QCardProps & TPropsWithClass = Object.freeze({
  bordered: true,
  class: 'q-pa-lg',
});
const iconAction: QIconProps & TPropsWithClass = Object.freeze({
  size: '1.2rem',
  class: 'cursor-pointer',
});
const tabPanels: Omit<QTabPanelsProps, 'modelValue'> & TPropsWithClass = Object.freeze({
  animated: false,
  class: 'shadow-3',
});
const tabPanel: Omit<QTabPanelProps, 'name'> & TPropsWithClass = Object.freeze({
  class: 'no-padding',
});
const input: Omit<QInputProps, 'modelValue'> = Object.freeze({
  outlined: true,
  dense: true,
  hideBottomSpace: true,
  bgColor: Dark.isActive ? 'black' : 'white',
  color: 'secondary',
});
const checkbox: Omit<QCheckboxProps, 'modelValue'> = Object.freeze({
  color: 'secondary',
});
const range: Omit<QRangeProps, 'modelValue'> = Object.freeze({
  color: 'secondary',
});
const smallInput: Omit<QInputProps, 'modelValue'> & TPropsWithClass = Object.freeze({
  ...input,
  class: 'no-margin',
});
const select: Omit<QSelectProps, 'modelValue'> = Object.freeze({
  ...input,
});
const toggle: Omit<QToggleProps, 'modelValue'> = Object.freeze({
  color: 'secondary',
});
const spinner: QSpinnerProps = Object.freeze({
  size: 'lg',
  color: 'secondary',
});
const chip: QChipProps = Object.freeze({
  dense: true,
  square: true,
  ripple: false,
});
const img: QImgProps = Object.freeze({
  noSpinner: true,
  noTransition: true,
});
const table: Omit<QTableProps, 'rows'> = Object.freeze({
  dense: true,
  bordered: true,
  separator: 'cell',
  rowKey: 'id',
  noDataLabel: 'Aucune donnée',
  noResultsLabel: 'Aucun résultat',
  loadingLabel: 'Chargement..',
});
const badge: QBadgeProps = Object.freeze({});
const menu: QMenuProps = Object.freeze({});
const listContextMenu: QListProps = Object.freeze({
  dense: true,
  separator: true,
  bordered: true,
});
const list: QListProps = Object.freeze({
  separator: true,
});
const dialog: QDialogProps = Object.freeze({
  backdropFilter: 'blur(4px)',
})

export const UiBindUtils = {
  btnRegular,
  btnPositiveSmall,
  btnWarning,
  btnNegative,
  btnPositive,
  btnMisc,
  btnIcon,
  tabs,
  tab,
  card,
  iconAction,
  tabPanel,
  tabPanels,
  input,
  checkbox,
  range,
  smallInput,
  select,
  toggle,
  spinner,
  chip,
  img,
  table,
  badge,
  menu,
  listContextMenu,
  list,
  dialog
};
                """
                File.write(filename, content)
                filename
            end

            def self.write_form_rules
                filename = 'form-rules.ts'
                content = """
function required(val: unknown) {
  if (val === null || val === undefined) return 'Ce champ est requis';
  if (typeof val === 'string' && val.trim().length === 0) return 'Ce champ est requis';
  return true;
}

export const FormRules = {
  required,
};
                """
                File.write(filename, content)
                filename
            end

            def self.write_document_utils
                filename = 'document-utils.ts'
                content = """
import { exportFile } from 'quasar';

function print(blob: Blob) {
  const blobUrl = URL.createObjectURL(blob);
  const iframe = document.createElement('iframe');
  iframe.style.display = 'none';
  iframe.src = blobUrl;
  document.body.appendChild(iframe);
  iframe.onload = () => {
    iframe.contentWindow?.print();
  };
}

function preview(blob: Blob) {
  const blobURL = window.URL.createObjectURL(blob);
  window.open(blobURL, '_blank');
}

function download(blob: Blob, filename: string) {
  exportFile(filename, blob);
}

function isReadable(filename: string) {
  const extension = filename.split('.').pop() ?? '';
  return ['pdf', 'jpeg', 'jpg'].includes(extension);
}

function isPrintable(filename: string) {
  const extension = filename.split('.').pop() ?? '';
  return extension == 'pdf';
}

function bufferToBlob(buffer: ArrayBuffer) {
  return new Blob([buffer])
}

function getSizeOfDocument(byteSize: number) {
  const sizeKb = byteSize / 1024;
  if (sizeKb >= 1000) {
    const sizeMb = sizeKb / 1024;
    return `${sizeMb.toFixed(1)} Mo`;
  }
  return `${sizeKb.toFixed(1)} Ko`;
};

export const DocumentUtils = {
  isReadable,
  isPrintable,
  print,
  preview,
  download,
  bufferToBlob,
  getSizeOfDocument
};

                """
                File.write(filename, content)
                filename
            end

            def self.write_date_utils
                filename = 'date-utils.ts'
                content = """
import { date } from 'quasar';

const isoDateFormat = 'YYYY-MM-DD';
const isoDatetimeFormat = 'YYYY-MM-DD HH:mm';
const appDateFormat = 'DD/MM/YYYY';
const appDatetimeFormat = 'DD/MM/YYYY HH:mm';
const appTimeFormat = 'HH:mm'
const dateFormatCalendar = 'YYYY-MM-DD';
const datetimeFormatCalendar = 'YYYY-MM-DD HH:mm';

function formatDateToAppFormat(dateArg: string) {
  return date.formatDate(dateArg, appDateFormat);
}
function formatDatetimeToAppFormat(dateArg: string) {
  return date.formatDate(dateArg, appDatetimeFormat);
}
function formatTimeToAppForm(dateArg: string) {
  return date.formatDate(dateArg, appTimeFormat)
}
function formatDateToIsoFormat(dateArg: string) {
  return date.formatDate(dateArg, isoDateFormat);
}
function formatDatetimeToIsoFormat(dateArg: string) {
  return date.formatDate(dateArg, isoDatetimeFormat);
}
function extractDateFromFormat(dateArg: string, format: string) {
  return date.extractDate(dateArg, format);
}
function formatDateCalendar(dateArg: string) {
  return date.formatDate(dateArg, dateFormatCalendar);
}
function formatDatetimeCalendar(dateArg: string) {
  return date.formatDate(dateArg, datetimeFormatCalendar);
}
function getDurationBetweenTwoDateInHour(date1Arg: string, date2Arg: string) {
  return date.getDateDiff(date1Arg, date2Arg, 'hours');
}
function formatDateToHHmm(dateArg: string) {
  return date.formatDate(dateArg, 'HH:mm');
}
function formatDateToHH(dateArg: string) {
  return date.formatDate(dateArg, 'HH');
}
function isDateIntervalInOtherInterval(
  dateInterval: [string, string],
  otherInterval: [string, string],
) {
  if (date.isBetweenDates(dateInterval[0], otherInterval[0], otherInterval[1])) {
    return true;
  }
  if (date.isBetweenDates(dateInterval[1], otherInterval[0], otherInterval[1])) {
    return true;
  }
  return false;
}
function getDateWeekNumber(dateArg: string) {
  const newDate = new Date(dateArg);
  const firstDay = new Date(newDate.getFullYear(), 0, 1);
  const days = Math.floor(date.getDateDiff(newDate, firstDay, 'seconds') / (24 * 60 * 60));
  return Math.ceil((days + firstDay.getDay() + 1) / 7);
}
function getDateMonthNumber(dateArg: string) {
  return new Date(dateArg).getMonth();
}
function getFrancePublicHolidays() {
  const currentYearMinusTwo = new Date().getFullYear() - 2;
  const publicHolidaysStatic = [
    '01/01', // Jour de l'an
    '05/01', // Fête du travail
    '05/08', // Victoire 1945
    '07/14', // Fête nationale
    '09/15', // Assomption
    '11/01', // Toussaint
    '11/11', // Armistice
    '12/25', // Noël
  ];
  const yearRange = new Array<number>(4)
    .fill(currentYearMinusTwo)
    .map((currentYearMinusTwo, index) => {
      return currentYearMinusTwo + index;
    });
  return yearRange.reduce((accumulator: string[], value) => {
    publicHolidaysStatic.forEach((publicHoliday) => {
      const newHolidayDate = formatDateCalendar(`${value}/${publicHoliday}`);
      accumulator.push(newHolidayDate);
    });
    accumulator.push(formatDateCalendar(lundiDePaques(value).toString())); // Lundi de Pâques
    accumulator.push(formatDateCalendar(ascension(value).toString())); // Ascension
    accumulator.push(formatDateCalendar(lundiPentecote(value).toString())); // Lundi de Pentecôte
    return accumulator;
  }, []);
}
function easterSunday(year: number) {
  const a = year % 19;
  const b = Math.floor(year / 100);
  const c = year % 100;
  const d = Math.floor(b / 4);
  const e = b % 4;
  const f = Math.floor((b + 8) / 25);
  const g = Math.floor((b - f + 1) / 3);
  const h = (19 * a + b - d - g + 15) % 30;
  const i = Math.floor(c / 4);
  const k = c % 4;
  const l = (32 + 2 * e + 2 * i - h - k) % 7;
  const m = Math.floor((a + 11 * h + 22 * l) / 451);
  const month = Math.floor((h + l - 7 * m + 114) / 31);
  const day = ((h + l - 7 * m + 114) % 31) + 1;
  return new Date(year, month - 1, day);
}
function lundiDePaques(year: number) {
  const d = easterSunday(year);
  d.setDate(d.getDate() + 1);
  return d;
}
function ascension(year: number) {
  const d = easterSunday(year);
  d.setDate(d.getDate() + 39);
  return d;
}
function lundiPentecote(year: number) {
  const d = easterSunday(year);
  d.setDate(d.getDate() + 50);
  return d;
}
function getBeautyDateMessage(dateArg: string) {
  if (date.formatDate(new Date(), appDateFormat) === date.formatDate(dateArg, appDateFormat)) {
    return date.formatDate(dateArg, appTimeFormat)
  }
  return date.formatDate(dateArg, appDatetimeFormat)
}

export const DateUtils = {
  appDateFormat,
  appDatetimeFormat,
  isoDateFormat,
  isoDatetimeFormat,
  formatDateToAppFormat,
  formatDatetimeToAppFormat,
  formatTimeToAppForm,
  formatDateToIsoFormat,
  formatDatetimeToIsoFormat,
  formatDateCalendar,
  formatDatetimeCalendar,
  extractDateFromFormat,
  getDurationBetweenTwoDateInHour,
  formatDateToHHmm,
  formatDateToHH,
  isDateIntervalInOtherInterval,
  getDateWeekNumber,
  getDateMonthNumber,
  getFrancePublicHolidays,
  getBeautyDateMessage
};
                """
                File.write(filename, content)
                filename
            end

            def self.write_use_cable
                filename = 'use-cable.ts'
                content = """
import { ref } from 'vue';
import { createConsumer } from '@rails/actioncable'

export type TActionCableData = {
  method: string;
  id?: number;
  type?: string;
  timeout?: number;
  message?: string;
  path?: string;
  state?: boolean;
}

export function useActionCable(
  channel = '',
  params = {},
  onReceived: (data: TActionCableData) => unknown,
  onConnected: () => unknown,
  onDisconnected: () => unknown
) {
  const cable = ref();
  const subscription = ref();

  function connect() {
    const url =
      process.env.ENDPOINT_URL?.replace('http', 'ws').replace('/api', '') +
      '/cable';
    cable.value = createConsumer(url);
    const aboParams = { channel: channel, ...params };
    subscription.value = cable.value.subscriptions.create(aboParams, {
      connected() {
        onConnected();
      },
      disconnected() {
        onDisconnected();
      },
      received(data: TActionCableData) {
        onReceived(data);
      },
    });
  }
  function disconnect() {
    if (!cable.value) {
      return;
    }
    subscription.value.disconnected();
    cable.value.subscriptions.remove(subscription.value);
    cable.value.disconnect();
  }

  return {
    connect,
    disconnect,
  };
}

                """
                File.write(filename, content)
                filename
            end
        end
    end
end
