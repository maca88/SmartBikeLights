import ColorIcon from "./ColorIcon";

export function createMenuItemColorTemplateFunc(iconForAll) {

  const menuItemColorTemplateFunc = (item) => {
    if (item.id <= 1 && !iconForAll) {
      return item.name;
    }

    return (
      <div>
        <ColorIcon color={item.id} /> <span>{item.name}</span>
      </div>);
  };

  return menuItemColorTemplateFunc;
}
